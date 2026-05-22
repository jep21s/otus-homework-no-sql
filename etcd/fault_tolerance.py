import os
import subprocess
import time
import sys

os.environ["PROTOCOL_BUFFERS_PYTHON_IMPLEMENTATION"] = "python"

import etcd3

ENDPOINTS = [
    ("etcd-1", "localhost", 2379),
    ("etcd-2", "localhost", 2479),
    ("etcd-3", "localhost", 2579),
]

ALL_CONTAINERS = ["etcd-1", "etcd-2", "etcd-3"]

STEP_WIDTH = 60


def print_step(title):
    print(f"\n{'=' * STEP_WIDTH}")
    print(f"  {title}")
    print(f"{'=' * STEP_WIDTH}")


def print_result(ok, message):
    status = "OK" if ok else "FAIL"
    print(f"  [{status}] {message}")


def docker_stop(container):
    subprocess.run(["docker", "stop", container], check=True, stdout=subprocess.DEVNULL)
    print(f"  Контейнер {container} остановлен")


def docker_start(container):
    subprocess.run(["docker", "start", container], check=True, stdout=subprocess.DEVNULL)
    print(f"  Контейнер {container} запущен")


def get_client(host="localhost", port=2379):
    return etcd3.client(host=host, port=port)


def try_write_read(label, host="localhost", port=2379, timeout=5):
    key = f"/test/{label}"
    value = f"value-{label}-{int(time.time())}"
    try:
        client = get_client(host, port)
        client.put(key, value)
        read_back = client.get(key)[0]
        if read_back.decode() == value:
            print_result(True, f"{label}: запись и чтение через {host}:{port}")
            return True
        else:
            print_result(False, f"{label}: данные не совпадают (ожидали '{value}', получили '{read_back}')")
            return False
    except Exception as e:
        print_result(False, f"{label}: ошибка через {host}:{port} — {e}")
        return False


def try_write_expect_fail(label, host="localhost", port=2379, timeout=5):
    key = f"/test/{label}"
    value = f"value-{label}-{int(time.time())}"
    try:
        client = get_client(host, port)
        client.put(key, value, timeout=timeout)
        read_back = client.get(key)[0]
        if read_back.decode() == value:
            print_result(False, f"{label}: запись удалась, хотя кворум должен быть потерян!")
            return False
        else:
            print_result(True, f"{label}: данные не совпадают (неожиданно)")
            return True
    except Exception:
        print_result(True, f"{label}: запись корректно отклонена (нет кворума)")
        return True


def get_first_alive_node():
    for name, host, port in ENDPOINTS:
        try:
            client = get_client(host, port)
            client.get("/test/probe")
            return name, host, port
        except Exception:
            continue
    return None


def main():
    print_step("ШАГ 1: Проверка работоспособности кластера (3 ноды)")
    alive = []
    for name, host, port in ENDPOINTS:
        ok = try_write_read(f"health-{name}", host, port)
        if ok:
            alive.append((name, host, port))
    if len(alive) < 3:
        print(f"\n  ВНИМАНИЕ: работает только {len(alive)}/3 нод. Убедитесь что кластер запущен: docker compose up -d")
        sys.exit(1)

    print_step("ШАГ 2: Запись тестовых данных в кластер")
    _, h, p = alive[0]
    client = get_client(h, p)
    for i in range(5):
        client.put(f"/test/key{i}", f"value{i}")
    for i in range(5):
        val = client.get(f"/test/key{i}")[0]
        print_result(val is not None, f"Ключ /test/key{i} = {val.decode() if val else 'None'}")

    print_step("ШАГ 3: Остановка одной ноды (etcd-3). Кворум 2/3 — должен работать.")
    docker_stop("etcd-3")
    time.sleep(3)

    step3_ok = True
    for name, host, port in [("etcd-1", "localhost", 2379), ("etcd-2", "localhost", 2479)]:
        if not try_write_read(f"failover-1node-{name}", host, port):
            step3_ok = False
    print()
    if step3_ok:
        print_result(True, "Кластер работает при потере 1 ноды (кворум сохранён)")
    else:
        print_result(False, "Кластер НЕ работает при потере 1 ноды")

    print_step("ШАГ 4: Остановка ещё одной ноды (etcd-2). Кворум потерян (1/3).")
    docker_stop("etcd-2")
    time.sleep(3)

    step4_ok = try_write_expect_fail("quorum-lost", "localhost", 2379)
    print()
    if step4_ok:
        print_result(True, "Кластер корректно отклоняет записи при потере кворума")
    else:
        print_result(False, "Кластер неожиданно принял запись без кворума")

    print_step("ШАГ 5: Восстановление etcd-2. Кворум 2/3 — должен снова работать.")
    docker_start("etcd-2")
    time.sleep(5)

    step5_ok = True
    for attempt in range(10):
        node = get_first_alive_node()
        if node:
            _, h, p = node
            if try_write_read("recovery-1node", h, p):
                step5_ok = True
                break
        time.sleep(2)
    else:
        step5_ok = False

    print()
    if step5_ok:
        print_result(True, "Кластер восстановлен после возврата 1 ноды")
    else:
        print_result(False, "Кластер НЕ восстановился")

    print_step("ШАГ 6: Восстановление etcd-3. Полный кластер 3/3.")
    docker_start("etcd-3")
    time.sleep(5)

    step6_ok = True
    for name, host, port in ENDPOINTS:
        if not try_write_read(f"full-recovery-{name}", host, port):
            step6_ok = False
    print()
    if step6_ok:
        print_result(True, "Все 3 ноды работают — кластер полностью восстановлен")
    else:
        print_result(False, "Не все ноды восстановились")

    print_step("ИТОГОВЫЙ ОТЧЁТ")
    results = {
        "Работа при 3/3 нодах": True,
        "Работа при потере 1 ноды (2/3)": step3_ok,
        "Отклонение записи при потере кворума (1/3)": step4_ok,
        "Восстановление при возврате 1 ноды (2/3)": step5_ok,
        "Полное восстановление кластера (3/3)": step6_ok,
    }
    all_ok = True
    for desc, ok in results.items():
        print_result(ok, desc)
        if not ok:
            all_ok = False

    print()
    if all_ok:
        print("  ВСЕ ТЕСТЫ ПРОЙДЕНЫ — кластер отказоустойчив!")
    else:
        print("  ЕСТЬ FAILURES — проверьте конфигурацию кластера")
        sys.exit(1)


if __name__ == "__main__":
    main()

// === Туроператоры ===

CREATE (:TourOperator {name: 'Солнечный Путь', country: 'Россия', founded: 2010});
CREATE (:TourOperator {name: 'GlobalTravel', country: 'США', founded: 2005});
CREATE (:TourOperator {name: 'AsiaTours', country: 'Китай', founded: 2012});
CREATE (:TourOperator {name: 'EuroRest', country: 'Германия', founded: 2008});
CREATE (:TourOperator {name: 'WarmWinds', country: 'ОАЭ', founded: 2015});

// === Страны ===

CREATE (:Country {name: 'Россия', code: 'RU'});
CREATE (:Country {name: 'Франция', code: 'FR'});
CREATE (:Country {name: 'Турция', code: 'TR'});
CREATE (:Country {name: 'Таиланд', code: 'TH'});
CREATE (:Country {name: 'Италия', code: 'IT'});
CREATE (:Country {name: 'Япония', code: 'JP'});
CREATE (:Country {name: 'Египет', code: 'EG'});
CREATE (:Country {name: 'Испания', code: 'ES'});
CREATE (:Country {name: 'Китай', code: 'CN'});
CREATE (:Country {name: 'ОАЭ', code: 'AE'});

// === Туристические локации ===

CREATE (:Destination {name: 'Озеро Байкал', type: 'природа'});
CREATE (:Destination {name: 'Мон Сен Мишель', type: 'историческое место'});
CREATE (:Destination {name: 'Каппадокия', type: 'природа'});
CREATE (:Destination {name: 'Пхукет', type: 'пляжный отдых'});
CREATE (:Destination {name: 'Амальфитанское побережье', type: 'пляжный отдых'});
CREATE (:Destination {name: 'Киото', type: 'историческое место'});
CREATE (:Destination {name: 'Пирамиды Гизы', type: 'историческое место'});
CREATE (:Destination {name: 'Севилья', type: 'культурный центр'});
CREATE (:Destination {name: 'Гуйлинь', type: 'природа'});
CREATE (:Destination {name: 'Рас-эль-Хайма', type: 'пляжный отдых'});

// === Города с аэропортами и/или вокзалами ===

CREATE (:City {name: 'Москва', has_airport: true, has_railway: true});
CREATE (:City {name: 'Иркутск', has_airport: true, has_railway: true});
CREATE (:City {name: 'Париж', has_airport: true, has_railway: true});
CREATE (:City {name: 'Рен', has_airport: false, has_railway: true});
CREATE (:City {name: 'Стамбул', has_airport: true, has_railway: true});
CREATE (:City {name: 'Невшехир', has_airport: true, has_railway: false});
CREATE (:City {name: 'Анталья', has_airport: true, has_railway: true});
CREATE (:City {name: 'Бангкок', has_airport: true, has_railway: true});
CREATE (:City {name: 'Пхукет', has_airport: true, has_railway: false});
CREATE (:City {name: 'Рим', has_airport: true, has_railway: true});
CREATE (:City {name: 'Неаполь', has_airport: true, has_railway: true});
CREATE (:City {name: 'Токио', has_airport: true, has_railway: true});
CREATE (:City {name: 'Осака', has_airport: true, has_railway: true});
CREATE (:City {name: 'Каир', has_airport: true, has_railway: true});
CREATE (:City {name: 'Луксор', has_airport: true, has_railway: true});
CREATE (:City {name: 'Мадрид', has_airport: true, has_railway: true});
CREATE (:City {name: 'Барселона', has_airport: true, has_railway: true});
CREATE (:City {name: 'Севилья', has_airport: true, has_railway: true});
CREATE (:City {name: 'Гуйлинь', has_airport: true, has_railway: true});
CREATE (:City {name: 'Дубай', has_airport: true, has_railway: true});
CREATE (:City {name: 'Рас-эль-Хайма', has_airport: false, has_railway: false});

// === Связи: Страна -> Локация (HAS_PLACE) ===

MATCH (c:Country {name: 'Россия'}), (d:Destination {name: 'Озеро Байкал'})
CREATE (c)-[:HAS_PLACE]->(d);

MATCH (c:Country {name: 'Франция'}), (d:Destination {name: 'Мон Сен Мишель'})
CREATE (c)-[:HAS_PLACE]->(d);

MATCH (c:Country {name: 'Турция'}), (d:Destination {name: 'Каппадокия'})
CREATE (c)-[:HAS_PLACE]->(d);

MATCH (c:Country {name: 'Таиланд'}), (d:Destination {name: 'Пхукет'})
CREATE (c)-[:HAS_PLACE]->(d);

MATCH (c:Country {name: 'Италия'}), (d:Destination {name: 'Амальфитанское побережье'})
CREATE (c)-[:HAS_PLACE]->(d);

MATCH (c:Country {name: 'Япония'}), (d:Destination {name: 'Киото'})
CREATE (c)-[:HAS_PLACE]->(d);

MATCH (c:Country {name: 'Египет'}), (d:Destination {name: 'Пирамиды Гизы'})
CREATE (c)-[:HAS_PLACE]->(d);

MATCH (c:Country {name: 'Испания'}), (d:Destination {name: 'Севилья'})
CREATE (c)-[:HAS_PLACE]->(d);

MATCH (c:Country {name: 'Китай'}), (d:Destination {name: 'Гуйлинь'})
CREATE (c)-[:HAS_PLACE]->(d);

MATCH (c:Country {name: 'ОАЭ'}), (d:Destination {name: 'Рас-эль-Хайма'})
CREATE (c)-[:HAS_PLACE]->(d);

// === Связи: Локация -> Ближайший город (NEAREST_CITY) ===

MATCH (d:Destination {name: 'Озеро Байкал'}), (c:City {name: 'Иркутск'})
CREATE (d)-[:NEAREST_CITY {distance_km: 65}]->(c);

MATCH (d:Destination {name: 'Мон Сен Мишель'}), (c:City {name: 'Рен'})
CREATE (d)-[:NEAREST_CITY {distance_km: 70}]->(c);

MATCH (d:Destination {name: 'Каппадокия'}), (c:City {name: 'Невшехир'})
CREATE (d)-[:NEAREST_CITY {distance_km: 40}]->(c);

MATCH (d:Destination {name: 'Каппадокия'}), (c:City {name: 'Анталья'})
CREATE (d)-[:NEAREST_CITY {distance_km: 300}]->(c);

MATCH (d:Destination {name: 'Пхукет'}), (c:City {name: 'Пхукет'})
CREATE (d)-[:NEAREST_CITY {distance_km: 0}]->(c);

MATCH (d:Destination {name: 'Амальфитанское побережье'}), (c:City {name: 'Неаполь'})
CREATE (d)-[:NEAREST_CITY {distance_km: 65}]->(c);

MATCH (d:Destination {name: 'Киото'}), (c:City {name: 'Осака'})
CREATE (d)-[:NEAREST_CITY {distance_km: 50}]->(c);

MATCH (d:Destination {name: 'Пирамиды Гизы'}), (c:City {name: 'Каир'})
CREATE (d)-[:NEAREST_CITY {distance_km: 25}]->(c);

MATCH (d:Destination {name: 'Севилья'}), (c:City {name: 'Севилья'})
CREATE (d)-[:NEAREST_CITY {distance_km: 0}]->(c);

MATCH (d:Destination {name: 'Гуйлинь'}), (c:City {name: 'Гуйлинь'})
CREATE (d)-[:NEAREST_CITY {distance_km: 0}]->(c);

MATCH (d:Destination {name: 'Рас-эль-Хайма'}), (c:City {name: 'Рас-эль-Хайма'})
CREATE (d)-[:NEAREST_CITY {distance_km: 0}]->(c);

// === Связи: Туроператор -> Локация (OFFERS) ===

MATCH (op:TourOperator {name: 'Солнечный Путь'}), (d:Destination {name: 'Озеро Байкал'})
CREATE (op)-[:OFFERS {price_from: 45000, season: 'лето'}]->(d);

MATCH (op:TourOperator {name: 'Солнечный Путь'}), (d:Destination {name: 'Каппадокия'})
CREATE (op)-[:OFFERS {price_from: 85000, season: 'весна'}]->(d);

MATCH (op:TourOperator {name: 'Солнечный Путь'}), (d:Destination {name: 'Пхукет'})
CREATE (op)-[:OFFERS {price_from: 95000, season: 'зима'}]->(d);

MATCH (op:TourOperator {name: 'GlobalTravel'}), (d:Destination {name: 'Мон Сен Мишель'})
CREATE (op)-[:OFFERS {price_from: 120000, season: 'лето'}]->(d);

MATCH (op:TourOperator {name: 'GlobalTravel'}), (d:Destination {name: 'Амальфитанское побережье'})
CREATE (op)-[:OFFERS {price_from: 150000, season: 'лето'}]->(d);

MATCH (op:TourOperator {name: 'GlobalTravel'}), (d:Destination {name: 'Севилья'})
CREATE (op)-[:OFFERS {price_from: 130000, season: 'весна'}]->(d);

MATCH (op:TourOperator {name: 'AsiaTours'}), (d:Destination {name: 'Киото'})
CREATE (op)-[:OFFERS {price_from: 110000, season: 'весна'}]->(d);

MATCH (op:TourOperator {name: 'AsiaTours'}), (d:Destination {name: 'Гуйлинь'})
CREATE (op)-[:OFFERS {price_from: 90000, season: 'осень'}]->(d);

MATCH (op:TourOperator {name: 'AsiaTours'}), (d:Destination {name: 'Озеро Байкал'})
CREATE (op)-[:OFFERS {price_from: 55000, season: 'зима'}]->(d);

MATCH (op:TourOperator {name: 'EuroRest'}), (d:Destination {name: 'Мон Сен Мишель'})
CREATE (op)-[:OFFERS {price_from: 115000, season: 'лето'}]->(d);

MATCH (op:TourOperator {name: 'EuroRest'}), (d:Destination {name: 'Севилья'})
CREATE (op)-[:OFFERS {price_from: 125000, season: 'осень'}]->(d);

MATCH (op:TourOperator {name: 'EuroRest'}), (d:Destination {name: 'Амальфитанское побережье'})
CREATE (op)-[:OFFERS {price_from: 145000, season: 'лето'}]->(d);

MATCH (op:TourOperator {name: 'EuroRest'}), (d:Destination {name: 'Киото'})
CREATE (op)-[:OFFERS {price_from: 105000, season: 'весна'}]->(d);

MATCH (op:TourOperator {name: 'WarmWinds'}), (d:Destination {name: 'Каппадокия'})
CREATE (op)-[:OFFERS {price_from: 80000, season: 'осень'}]->(d);

MATCH (op:TourOperator {name: 'WarmWinds'}), (d:Destination {name: 'Пхукет'})
CREATE (op)-[:OFFERS {price_from: 90000, season: 'зима'}]->(d);

MATCH (op:TourOperator {name: 'WarmWinds'}), (d:Destination {name: 'Рас-эль-Хайма'})
CREATE (op)-[:OFFERS {price_from: 70000, season: 'зима'}]->(d);

MATCH (op:TourOperator {name: 'WarmWinds'}), (d:Destination {name: 'Пирамиды Гизы'})
CREATE (op)-[:OFFERS {price_from: 100000, season: 'весна'}]->(d);

// === Маршруты: Наземный транспорт (двунаправленные) ===

MATCH (c1:City {name: 'Москва'}), (c2:City {name: 'Иркутск'})
CREATE (c1)-[:ROUTE {transport: 'train', distance: 5200}]->(c2),
       (c2)-[:ROUTE {transport: 'train', distance: 5200}]->(c1);

MATCH (c1:City {name: 'Париж'}), (c2:City {name: 'Рен'})
CREATE (c1)-[:ROUTE {transport: 'train', distance: 350}]->(c2),
       (c2)-[:ROUTE {transport: 'train', distance: 350}]->(c1);

MATCH (c1:City {name: 'Париж'}), (c2:City {name: 'Барселона'})
CREATE (c1)-[:ROUTE {transport: 'train', distance: 1030}]->(c2),
       (c2)-[:ROUTE {transport: 'train', distance: 1030}]->(c1);

MATCH (c1:City {name: 'Барселона'}), (c2:City {name: 'Мадрид'})
CREATE (c1)-[:ROUTE {transport: 'train', distance: 620}]->(c2),
       (c2)-[:ROUTE {transport: 'train', distance: 620}]->(c1);

MATCH (c1:City {name: 'Мадрид'}), (c2:City {name: 'Севилья'})
CREATE (c1)-[:ROUTE {transport: 'train', distance: 470}]->(c2),
       (c2)-[:ROUTE {transport: 'train', distance: 470}]->(c1);

MATCH (c1:City {name: 'Рим'}), (c2:City {name: 'Неаполь'})
CREATE (c1)-[:ROUTE {transport: 'train', distance: 220}]->(c2),
       (c2)-[:ROUTE {transport: 'train', distance: 220}]->(c1);

MATCH (c1:City {name: 'Рим'}), (c2:City {name: 'Мадрид'})
CREATE (c1)-[:ROUTE {transport: 'train', distance: 1960}]->(c2),
       (c2)-[:ROUTE {transport: 'train', distance: 1960}]->(c1);

MATCH (c1:City {name: 'Токио'}), (c2:City {name: 'Осака'})
CREATE (c1)-[:ROUTE {transport: 'train', distance: 500}]->(c2),
       (c2)-[:ROUTE {transport: 'train', distance: 500}]->(c1);

MATCH (c1:City {name: 'Стамбул'}), (c2:City {name: 'Анталья'})
CREATE (c1)-[:ROUTE {transport: 'bus', distance: 600}]->(c2),
       (c2)-[:ROUTE {transport: 'bus', distance: 600}]->(c1);

MATCH (c1:City {name: 'Анталья'}), (c2:City {name: 'Невшехир'})
CREATE (c1)-[:ROUTE {transport: 'bus', distance: 560}]->(c2),
       (c2)-[:ROUTE {transport: 'bus', distance: 560}]->(c1);

MATCH (c1:City {name: 'Бангкок'}), (c2:City {name: 'Пхукет'})
CREATE (c1)-[:ROUTE {transport: 'bus', distance: 840}]->(c2),
       (c2)-[:ROUTE {transport: 'bus', distance: 840}]->(c1);

MATCH (c1:City {name: 'Каир'}), (c2:City {name: 'Луксор'})
CREATE (c1)-[:ROUTE {transport: 'train', distance: 650}]->(c2),
       (c2)-[:ROUTE {transport: 'train', distance: 650}]->(c1);

MATCH (c1:City {name: 'Дубай'}), (c2:City {name: 'Рас-эль-Хайма'})
CREATE (c1)-[:ROUTE {transport: 'bus', distance: 100}]->(c2),
       (c2)-[:ROUTE {transport: 'bus', distance: 100}]->(c1);

// === Маршруты: Авиа ===

MATCH (c1:City {name: 'Москва'}), (c2:City {name: 'Париж'})
CREATE (c1)-[:ROUTE {transport: 'plane', distance: 2850}]->(c2);

MATCH (c1:City {name: 'Москва'}), (c2:City {name: 'Стамбул'})
CREATE (c1)-[:ROUTE {transport: 'plane', distance: 2100}]->(c2);

MATCH (c1:City {name: 'Москва'}), (c2:City {name: 'Токио'})
CREATE (c1)-[:ROUTE {transport: 'plane', distance: 7500}]->(c2);

MATCH (c1:City {name: 'Москва'}), (c2:City {name: 'Дубай'})
CREATE (c1)-[:ROUTE {transport: 'plane', distance: 4600}]->(c2);

MATCH (c1:City {name: 'Париж'}), (c2:City {name: 'Рим'})
CREATE (c1)-[:ROUTE {transport: 'plane', distance: 1430}]->(c2);

MATCH (c1:City {name: 'Париж'}), (c2:City {name: 'Мадрид'})
CREATE (c1)-[:ROUTE {transport: 'plane', distance: 1270}]->(c2);

MATCH (c1:City {name: 'Стамбул'}), (c2:City {name: 'Каир'})
CREATE (c1)-[:ROUTE {transport: 'plane', distance: 1250}]->(c2);

MATCH (c1:City {name: 'Стамбул'}), (c2:City {name: 'Бангкок'})
CREATE (c1)-[:ROUTE {transport: 'plane', distance: 7600}]->(c2);

MATCH (c1:City {name: 'Токио'}), (c2:City {name: 'Гуйлинь'})
CREATE (c1)-[:ROUTE {transport: 'plane', distance: 3200}]->(c2);

MATCH (c1:City {name: 'Дубай'}), (c2:City {name: 'Каир'})
CREATE (c1)-[:ROUTE {transport: 'plane', distance: 2400}]->(c2);

MATCH (c1:City {name: 'Дубай'}), (c2:City {name: 'Москва'})
CREATE (c1)-[:ROUTE {transport: 'plane', distance: 4600}]->(c2);

MATCH (c1:City {name: 'Рим'}), (c2:City {name: 'Мадрид'})
CREATE (c1)-[:ROUTE {transport: 'plane', distance: 1360}]->(c2);

MATCH (c1:City {name: 'Каир'}), (c2:City {name: 'Стамбул'})
CREATE (c1)-[:ROUTE {transport: 'plane', distance: 1250}]->(c2);

MATCH (c1:City {name: 'Бангкок'}), (c2:City {name: 'Стамбул'})
CREATE (c1)-[:ROUTE {transport: 'plane', distance: 7600}]->(c2);

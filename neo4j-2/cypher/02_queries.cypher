// Туроператор -> Страна -> Локация -> Ближайший город -> ... наземные маршруты ... -> Город -> Локация

MATCH (op:TourOperator)-[:OFFERS]->(dest1:Destination)<-[:HAS_PLACE]-(country1:Country),
      (dest1)-[:NEAREST_CITY]->(city1:City),
      path = (city1)-[:ROUTE*1..5]->(city2:City),
      (city2)<-[:NEAREST_CITY]-(dest2:Destination)<-[:HAS_PLACE]-(country2:Country),
      (op2:TourOperator)-[:OFFERS]->(dest2)
WHERE ALL(r IN relationships(path) WHERE r.transport IN ['train', 'bus'])
  AND dest1.name <> dest2.name
RETURN
  op.name AS tour_operator,
  country1.name AS from_country,
  dest1.name AS from_destination,
  city1.name AS from_city,
  [node IN nodes(path) | node.name] AS ground_route,
  [r IN relationships(path) | r.transport + ' (' + r.distance + ' км)'] AS route_details,
  reduce(total = 0, r IN relationships(path) | total + r.distance) AS total_distance_km,
  length(path) AS hops,
  city2.name AS to_city,
  dest2.name AS to_destination,
  country2.name AS to_country
ORDER BY total_distance_km;

// Индексы для ускорения запроса

CREATE INDEX city_name_index IF NOT EXISTS
FOR (c:City) ON (c.name);

CREATE INDEX destination_name_index IF NOT EXISTS
FOR (d:Destination) ON (d.name);

CREATE INDEX tour_operator_name_index IF NOT EXISTS
FOR (t:TourOperator) ON (t.name);

CREATE INDEX country_name_index IF NOT EXISTS
FOR (c:Country) ON (c.name);

CREATE INDEX route_transport_index IF NOT EXISTS
FOR ()-[r:ROUTE]-() ON (r.transport);


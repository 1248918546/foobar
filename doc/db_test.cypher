//drop table
MATCH (n)
DETACH DELETE n;

//show table
MATCH (n)
RETURN n;

//Find one's friends
MATCH (a:Person {uid: 10001})-[:FRIEND]-(b:Person)
RETURN b;

//Find one's friend's friends that are't one's friends, a.k.a. Possible Friends.
MATCH (a:Person {uid: 10002})-[:FRIEND]-(b:Person)-[:FRIEND]-(c:Person)
  WHERE NOT (a)-[:FRIEND]-(c)
RETURN b, c;
//only persons
MATCH (a:Person {uid: 10002})-[:FRIEND]-(b:Person)-[:FRIEND]-(c:Person)
  WHERE NOT (a)-[:FRIEND]-(c)
RETURN DISTINCT c;
//Mediation
MATCH (a:Person {uid: 10002})-[:FRIEND]-(b:Person)-[:FRIEND]-(c:Person {uid: 10003})
RETURN DISTINCT b;
//one path
MATCH p = allShortestPaths(
(:Person {uid: 10002})-[:FRIEND*]-(:Person {uid: 10003})
)
RETURN p;

//Find one's papers
MATCH (:Person {uid: 10000})-[r:PUBLISH]->(p)
RETURN r.timestamp, p
  ORDER BY r.timestamp DESC
  SKIP 0
  LIMIT 10;

//Find one's papers with privilege check. (e.g., 10001 can while 10000 can't get 10002's paper)
MATCH (src:Person {uid: 10001})-[:FRIEND*0..1]-(dst:Person {uid: 10002})-[r:PUBLISH]->(p:Paper)
RETURN r.timestamp, p
  ORDER BY r.timestamp DESC
  SKIP 0
  LIMIT 10;

//Find friends' papers
MATCH (a:Person {uid: 10001})-[:FRIEND]-(b)-[r:PUBLISH]->(p)
RETURN r.timestamp, p
  ORDER BY r.timestamp DESC
  SKIP 0
  LIMIT 10;

//Find one's timeline, i.e, one and its friends' papers
MATCH (a:Person {uid: 10001})-[:FRIEND*0..1]-(b)-[r:PUBLISH]->(p)
RETURN b, r, p
  ORDER BY r.timestamp DESC
  SKIP 0
  LIMIT 10;

//register
CREATE (:Account {username: 'betty', password: '2'})-[:LINK]->(:Person {uid: 20001, nickname: 'Betty'});

//publish
MATCH (a:Person {uid: 20001})
CREATE (a)-[:PUBLISH {timestamp: 1544031800374}]->(p:Paper {pid: 40008, title: 'Intro', content: "I'm Betty."})
CREATE (a)-[:PUBLISH {timestamp: 1544031582374}]->(q:Paper {pid: 40009, title: 'fsdhg', content: 'aregh'});

//undo publish
MATCH (a:Person {nickname: 'Betty'})-[:PUBLISH]->(p:Paper {pid: 40009})
DETACH DELETE p;

//delete person
MATCH (account)-[:LINK]->(person:Person {uid: 20001})
OPTIONAL MATCH (person)-[:PUBLISH]->(paper:Paper)
DETACH DELETE person, account, paper;

//create friend request
MATCH (src:Person {uid: 10000})
MATCH (dst:Person {uid: 20001})
  WHERE NOT ((src)-[:FRIEND]-(dst) OR (src)-[:INVITE]-(dst))
CREATE (src)-[:INVITE {timestamp: 1544031402374, message: 'Hello.'}]->(dst);

//revoke friend request
MATCH (src:Person {uid: 10000})-[r:INVITE]->(dst:Person {uid: 20001})
DELETE r;

//check import friend requests
MATCH (src:Person)-[r:INVITE]->(dst:Person {uid: 20001})
RETURN src, r
  ORDER BY r.timestamp DESC;

//check export friend requests
MATCH (src:Person {uid: 10000})-[r:INVITE]->(dst:Person)
RETURN dst, r
  ORDER BY r.timestamp;

//accept friend request
MATCH (src:Person {uid: 10000})-[r:INVITE]->(dst:Person {uid: 20001})
DELETE r
CREATE (src)-[:FRIEND]->(dst);

//break friendship
MATCH (src:Person {uid: 10000})-[r:FRIEND]-(dst:Person {uid: 20001})
DELETE r;

//start friendship
MATCH (src:Person {uid: 10000})
MATCH (dst:Person {uid: 20001})
  WHERE NOT ((src)-[:FRIEND]-(dst) OR (src)-[:INVITE]-(dst))
CREATE (src)-[:FRIEND]->(dst);

//retrieve password
MATCH (account:Account {username: 'realDT'})
RETURN account.password;

//find max uid
MATCH (p:Person)
RETURN p.uid AS num
  ORDER BY num DESC
  LIMIT 1;

//find max pid
MATCH (p:Paper)
RETURN p.pid AS num
  ORDER BY num DESC
  LIMIT 1;

//find uid by username
MATCH (account:Account {username: 'realDT'})-[l:LINK]->(person:Person)
RETURN person.uid;

//check account existence with given username
MATCH (a:Account{username:'realDT'}) RETURN count(a)<>0;

//update password by uid
MATCH (a:Account)-[r:LINK]->(p:Person {uid:10002})
SET a.password='password'
RETURN a,r,p;

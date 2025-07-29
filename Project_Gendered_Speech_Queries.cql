
// 1. Gender Split: Create Male and Female nodes

// Create MaleCharacter nodes
MATCH (c:Character)-[:SPEAKS_IN]->(p:Play)
WHERE c.gender = "MALE"
MERGE (mc:MaleCharacter {id: c.id, play: p.title})
SET mc.words = c.total_words,
    mc.gender = "MALE",
    mc.play = p.title
MERGE (p)-[:HAS_CHARACTER]->(mc);

// Create FemaleCharacter nodes
MATCH (c:Character)-[:SPEAKS_IN]->(p:Play)
WHERE c.gender = "FEMALE"
MERGE (fc:FemaleCharacter {id: c.id, play: p.title})
SET fc.words = c.total_words,
    fc.gender = "FEMALE",
    fc.play = p.title
MERGE (p)-[:HAS_CHARACTER]->(fc);


// 2. Calculate total word counts by gender

MATCH (c)
WHERE c:MaleCharacter OR c:FemaleCharacter
RETURN 
  SUM(CASE WHEN c:MaleCharacter THEN c.words ELSE 0 END) AS TotalMaleWords,
  SUM(CASE WHEN c:FemaleCharacter THEN c.words ELSE 0 END) AS TotalFemaleWords;


// 3. Find plays with balanced gender speech

MATCH (p:Play)-[:HAS_CHARACTER]->(c)
WHERE c:MaleCharacter OR c:FemaleCharacter
WITH 
  p.title AS PlayTitle,
  SUM(CASE WHEN c:MaleCharacter THEN c.words ELSE 0 END) AS MaleWords,
  SUM(CASE WHEN c:FemaleCharacter THEN c.words ELSE 0 END) AS FemaleWords
WITH PlayTitle, MaleWords, FemaleWords, abs(MaleWords - FemaleWords) AS Diff
WHERE Diff < 0.1 * MaleWords
RETURN PlayTitle, MaleWords, FemaleWords, Diff
ORDER BY Diff ASC;


// 4. Label balanced plays

MATCH (p:Play)-[:HAS_CHARACTER]->(c)
WHERE c:MaleCharacter OR c:FemaleCharacter
WITH 
  p,
  SUM(CASE WHEN c:MaleCharacter THEN c.words ELSE 0 END) AS MaleWords,
  SUM(CASE WHEN c:FemaleCharacter THEN c.words ELSE 0 END) AS FemaleWords
WITH p, abs(MaleWords - FemaleWords) AS Diff, MaleWords
WHERE Diff < 0.1 * MaleWords
SET p:BalancedPlay
RETURN p.title, MaleWords, FemaleWords, Diff;


// 5. Find the dominant speaker in a play

MATCH (p:Play {title: "Der Tod Adams"})-[:HAS_CHARACTER]->(c)
RETURN c.id, c.gender, c.words
ORDER BY c.words DESC
LIMIT 1;


// 6. Visualise all characters of a play

MATCH (p:Play {title: "Der Tod Adams"})-[:HAS_CHARACTER]->(c)
RETURN p, c;


// 7. Create GenderTotal summary nodes

MATCH (c:MaleCharacter)
WITH SUM(c.words) AS MaleWords
MERGE (m:GenderTotal {gender: "male"})
SET m.words = MaleWords;

MATCH (c:FemaleCharacter)
WITH SUM(c.words) AS FemaleWords
MERGE (f:GenderTotal {gender: "female"})
SET f.words = FemaleWords;

MATCH (m:GenderTotal), (f:GenderTotal)
RETURN m, f;

-- Урок 8. Вебинар. Сложные запросы

-- Задание: Переписать запросы, заданые к ДЗ урока 6 с использованием JOIN

   
-- 3. Определить кто больше поставил лайков (всего) - мужчины или женщины?

SELECT profiles.gender
  FROM profiles
   JOIN likes
     ON profiles.user_id = likes.user_id;

    
SELECT profiles.gender, COUNT(target_id) AS total
  FROM profiles
   JOIN likes
     ON profiles.user_id = likes.user_id
  GROUP BY gender
  ORDER BY total DESC;


-- Следующие два задания не получилось полностью сделать. После вебинара доведу их "до ума".
 
 
-- 4. Подсчитать общее количество лайков десяти самым молодым пользователям (сколько лайков получили 10 самых молодых пользователей).

 
-- вариант №1 
 
SELECT profiles.birthday, COUNT(target_id) AS total
  FROM profiles
   LEFT JOIN likes
     ON profiles.user_id = likes.user_id
       AND target_type_id = 2
  ORDER BY birthday;
      
-- DESC LIMIT 10;
-- ORDER BY birthday
 
 
 -- вариант №2
 
SELECT CONCAT(first_name, " ", last_name) as user, TIMESTAMPDIFF(YEAR, birthday, NOW()) as age 
  FROM users
    JOIN profiles
      ON users.id = profiles.user_id
        ORDER BY age LIMIT 10;


SELECT COUNT(likes.id)
  FROM users
    LEFT JOIN profiles
      ON users.id = profiles.user_id
	JOIN likes
      ON users.id = likes.user_id
	ORDER BY TIMESTAMPDIFF(YEAR, birthday, NOW()) LIMIT 10;
 
 
-- базовый код.

SELECT 
  (SELECT COUNT(*) FROM likes WHERE target_id = profiles.user_id AND target_type_id = 2) AS likes_total  
  FROM profiles 
  ORDER BY birthday 
  DESC LIMIT 10;


SELECT SUM(likes_total) FROM  
  (SELECT 
    (SELECT COUNT(*) FROM likes WHERE target_id = profiles.user_id AND target_type_id = 2) AS likes_total  
    FROM profiles 
    ORDER BY birthday 
    DESC LIMIT 10) AS user_likes
;
     

-- 5. Найти 10 пользователей, которые проявляют наименьшую активность в использовании социальной сети


SELECT CONCAT(first_name, ' ', last_name) as user, GREATEST(IFNULL(MAX(likes.created_at), 0), IFNULL(MAX(media.created_at),0), IFNULL(MAX(messages.created_at),0)) as overall_activity
  FROM users
   JOIN likes
     ON likes.user_id = users.id
   JOIN media
     ON media.user_id = users.id
   JOIN messages
     ON messages.from_user_id = users.id
  ORDER BY overall_activity
  LIMIT 10;
   

-- базовый код.

SELECT 
  CONCAT(first_name, ' ', last_name) AS user, 
	(SELECT COUNT(*) FROM likes WHERE likes.user_id = users.id) + 
	(SELECT COUNT(*) FROM media WHERE media.user_id = users.id) + 
	(SELECT COUNT(*) FROM messages WHERE messages.from_user_id = users.id) AS overall_activity 
	  FROM users
	  ORDER BY overall_activity
	  LIMIT 10;
	 


   
 
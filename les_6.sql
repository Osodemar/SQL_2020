-- "Урок 6. Вебинар. Операторы, фильтрация, сортировка и ограничение. Агрегация данных".


-- 1. Создать и заполнить таблицы лайков и постов.


-- Таблица лайков
DROP TABLE IF EXISTS likes;
CREATE TABLE likes (
  id INT UNSIGNED NOT NULL AUTO_INCREMENT PRIMARY KEY,
  user_id INT UNSIGNED NOT NULL,
  target_id INT UNSIGNED NOT NULL,
  target_type_id INT UNSIGNED NOT NULL,
  created_at DATETIME DEFAULT CURRENT_TIMESTAMP
);

-- Таблица типов лайков
DROP TABLE IF EXISTS target_types;
CREATE TABLE target_types (
  id INT UNSIGNED NOT NULL AUTO_INCREMENT PRIMARY KEY,
  name VARCHAR(255) NOT NULL UNIQUE,
  created_at DATETIME DEFAULT CURRENT_TIMESTAMP
);

INSERT INTO target_types (name) VALUES 
  ('messages'),
  ('users'),
  ('media'),
  ('posts');
 
 -- Заполняем лайки
INSERT INTO likes 
  SELECT 
    id, 
    FLOOR(1 + (RAND() * 100)), 
    FLOOR(1 + (RAND() * 100)),
    FLOOR(1 + (RAND() * 4)),
    CURRENT_TIMESTAMP 
  FROM messages;
 
 
 -- Создадим таблицу постов
CREATE TABLE posts (
  id INT UNSIGNED NOT NULL AUTO_INCREMENT PRIMARY KEY,
  user_id INT UNSIGNED NOT NULL,
  community_id INT UNSIGNED,
  head VARCHAR(255),
  body TEXT NOT NULL,
  media_id INT UNSIGNED,
  is_public BOOLEAN DEFAULT TRUE,
  is_archived BOOLEAN DEFAULT FALSE,
  created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
  updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
);
 

-- "Доработка" данных таблицы posts.

UPDATE posts SET updated_at = NOW() WHERE updated_at < created_at;
UPDATE posts SET user_id = FLOOR(1 + RAND() * 100);
UPDATE posts SET community_id = FLOOR(1 + RAND() * 84);
UPDATE posts SET media_id = FLOOR(1 + RAND() * 100);
UPDATE posts SET is_public = 0 WHERE is_public = is_archived;





 -- 2. Создать все необходимые внешние ключи и диаграмму отношений.
 

DESC profiles;

ALTER TABLE profiles
  ADD CONSTRAINT profiles_user_id_fk
    FOREIGN KEY (user_id) REFERENCES users(id)
      ON DELETE CASCADE,
        ADD CONSTRAINT profiles_photo_id_fk
    FOREIGN KEY (photo_id) REFERENCES media(id)
      ON DELETE SET NULL,
        ADD CONSTRAINT profiles_status_id_fk
    FOREIGN KEY (status_id) REFERENCES profile_statuses(id)
      ON DELETE SET NULL,
        ADD CONSTRAINT profiles_city_id_fk
    FOREIGN KEY (city_id) REFERENCES cities(id)
      ON DELETE SET NULL;

     
-- Изменяем тип столбца при необходимости
ALTER TABLE profiles MODIFY COLUMN status_id INT UNSIGNED;
-- ALTER TABLE profiles DROP FOREIGN KEY profiles_user_id_fk;
-- ALTER TABLE profiles MODIFY COLUMN photo_id INT(10) UNSIGNED;
-- ALTER TABLE table_name DROP FOREIGN KEY constraint_name;  COMMENT "Если нужно удалить"



DESC messages;

ALTER TABLE messages
  ADD CONSTRAINT messages_from_user_id_fk 
    FOREIGN KEY (from_user_id) REFERENCES users(id),
  ADD CONSTRAINT messages_to_user_id_fk 
    FOREIGN KEY (to_user_id) REFERENCES users(id);

   
   
DESC communities_users;

ALTER TABLE communities_users
  ADD CONSTRAINT communities_users_user_id_fk 
    FOREIGN KEY (user_id) REFERENCES users(id);
   
ALTER TABLE communities_users
  ADD CONSTRAINT communities_users_communities_id_fk 
    FOREIGN KEY (community_id) REFERENCES communities(id);

   
      
DESC posts;
  
ALTER TABLE posts
  ADD CONSTRAINT posts_user_id_fk 
    FOREIGN KEY (user_id) REFERENCES users(id);
    
ALTER TABLE posts
   ADD CONSTRAINT media_id_fk
      FOREIGN KEY (media_id) REFERENCES media(id);

     
       
DESC friendships;
   
ALTER TABLE friendships
  ADD CONSTRAINT friendships_user_id_fk
    FOREIGN KEY (friend_id) REFERENCES users(id)
      ON DELETE CASCADE;
      
   ALTER TABLE friendships   
        ADD CONSTRAINT friendships_friendship_statuses_id_fk
    FOREIGN KEY (status_id) REFERENCES friendship_statuses(id);
   
   
DESC likes;

ALTER TABLE likes
  ADD CONSTRAINT likes_user_id_fk
    FOREIGN KEY (user_id) REFERENCES users(id),
        ADD CONSTRAINT likes_target_type_id_fk
    FOREIGN KEY (target_type_id) REFERENCES target_types(id);



DESC media;

ALTER TABLE media
  ADD CONSTRAINT media_user_id_fk 
    FOREIGN KEY (user_id) REFERENCES users(id),
  ADD CONSTRAINT media_to_media_types_id_fk 
    FOREIGN KEY (media_type_id) REFERENCES media_types(id);

  
   
DESC cities;

ALTER TABLE cities
  ADD CONSTRAINT cities_countries_id_fk 
    FOREIGN KEY (country_id) REFERENCES countries(id);

 
   
   
-- 3. Определить кто больше поставил лайков (всего) - мужчины или женщины?

SELECT
	(SELECT gender FROM profiles WHERE user_id = likes.user_id) AS gender
    FROM likes; 

SELECT
	(SELECT gender FROM profiles WHERE user_id = likes.user_id) AS gender,
	COUNT(*) AS total
    FROM likes
    GROUP BY gender
    ORDER BY total DESC
    LIMIT 1;

-- 4. Подсчитать общее количество лайков десяти самым молодым пользователям (сколько лайков получили 10 самых молодых пользователей).


SELECT * FROM target_types;

SELECT * FROM profiles ORDER BY birthday DESC LIMIT 10;

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

SELECT 
  CONCAT(first_name, ' ', last_name) AS user, 
	(SELECT COUNT(*) FROM likes WHERE likes.user_id = users.id) + 
	(SELECT COUNT(*) FROM media WHERE media.user_id = users.id) + 
	(SELECT COUNT(*) FROM messages WHERE messages.from_user_id = users.id) AS overall_activity 
	  FROM users
	  ORDER BY overall_activity
	  LIMIT 10;
	 
	 
   

   
 
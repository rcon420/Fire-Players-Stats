Информация/особенности (в сравнении с Levels Ranks) статистики:
 - Поддержка только CS:GO.
 - Статистики работает на основе формулы ELO [Levels Ranks](https://github.com/levelsranks/levels-ranks-core) (за основу бралась именно она).
 - Статистика работает только с MySQL и расчитана на работу с ВЕБом.
 - Количетсво рангов неограничено. Настройка произвордися напрямую с БД или через ВЕБ.
 - Совмещенная база данных на нескольких серверов (по принципу випки от Рико).
 - Статистика по оружию хранится в отдельной таблице, из-за чего при выходе нового оружия изменять плагин и БД не прийдется.
 - Попытка исправить превосходство новых игроков перед старыми в получении поинтов.
 - Начисление срика возможно только в течении 10 сек после убийства, после чего идет обнуление.
 - Можно установить лимит обнуления статистики по времени для пользователя.
 - Минимизирована информация об получаемых очках.
 - Важной особенностью данного плагина можно отметить неизменное API и переводы при обновлениях. =)

Команды плагина:
*!position !pos* - Позиция игрока на сервере.
*!stats !rank !fps* - Главное меню статистики.
*!top* - Топ лучших игроков.
*!toptime* - Топ игроков по наиграному времени.

В `addons/sourcemod/configs/databases.cfg` добавьте секцию с вашими настройками, пример:
```
"fire_players_statis"
{
	"driver"			"mysql"
	"host"				""
	"database"			""
	"user"				""
	"pass"				""
}
```

Запрос для добавления стандартных настроек рангов:
```sql
INSERT INTO `fps_test`.`fps_ranks` (`rank_id`, `rank_name`, `points`) 
	VALUES 
		('1', 'Silver I', '650'),
		('1', 'Silver II', '700'), 
		('1', 'Silver III', '800'), 
		('1', 'Silver IV', '850'), 
		('1', 'Silver Elite', '900'), 
		('1', 'Silver Elite Master', '925'), 
		('1', 'Gold Nova I', '950'), 
		('1', 'Gold Nova II', '975'), 
		('1', 'Gold Nova III', '1000'), 
		('1', 'Gold Nova Master', '1100'), 
		('1', 'Master Guardian I', '1250'), 
		('1', 'Master Guardian II', '1400'), 
		('1', 'Master Guardian Elite', '1600'), 
		('1', 'Distinguished Master Guardian', '1800'), 
		('1', 'Legendary Eagle', '2100'), 
		('1', 'Legendary Eagle Master', '2400'), 
		('1', 'Supreme Master First Class', '3000'), 
		('1', 'The Global Elite', '4000');
```

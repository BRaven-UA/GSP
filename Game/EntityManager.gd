# Синглтон менеджер сущностей. Все операции с сущностями должны проходить через этот синглтон

extends Node

enum TYPES {BIOLOGICAL, MECHANICAL, DIGITAL, MENTAL} # перечень типов для атрибута TYPE
enum GROUPS {NOTES, FOOD, PERK} # перечень групп, для объединения разных типов сущностей
enum CLASSES {CREATURE, ITEM, ABILITY}
enum REMAINS {ONLY_NOTEBOOK, NO_FOOD, NO_PETS}
enum {NAME, CLASS, DESCRIPTION, HEALTH, TYPE, GROUP, CHANGE_HEALTH, CONSUMABLES, CAPACITY, QUANTITY, COST, ACTIVE, KNOWLEDGE, ATTACHMENT} # перечень атрибутов
const MAX_STUDY: int = 10 # максимальный уровень изучения знания
const ATTRIBUTES := ["NAME", "CLASS", "DESCRIPTION", "HEALTH", "TYPE", "GROUP", "CHANGE_HEALTH", "CONSUMABLES", "CAPACITY", "QUANTITY", "COST", "ACTIVE", "KNOWLEDGE", "ATTACHMENT"] # не хочу давать имя enum, так как в коде плохо читается

const ENTITIES := [
	{NAME:"Записная книжка", CLASS:CLASSES.ITEM, DESCRIPTION:"Сильно потрепана, многие страницы вырваны, некоторые повреждены, текст в некоторых местах невозможно прочитать."},
		{NAME:"Записка 1", CLASS:CLASSES.ITEM, DESCRIPTION:"Начинаю записывать свои наблюдения, так как их становится все больше.\nЭта вспышка нового вируса все чаще мелькает в сводках новостей. Сперва я не обращал на нее внимания - такие вспышки не редкость в последнее время. Но потом мне на почту пришло письмо от моего знакомого из [color=aqua][url=Университет]университета[/url][/color] неподалеку от очага распространения. По специальности он зоолог, но вопрос его касался механизмов связывания белковых соединений с клеточной мембраной животных. Этот вопрос натолкнул меня на мысль о зоонозном происхождении вируса.", GROUP:GROUPS.NOTES},
		{NAME:"Записка 2", CLASS:CLASSES.ITEM, DESCRIPTION:"Случаи заражения уже зарегистрированы в нескольких странах. Судя по всему вирус передается не только при тесном контакте. Симптомы у заразившихся самые разные и пока не понятно на какие органы воздействует вирус, а также к какому семейству он принадлежит.\nЗнакомый из [color=aqua][url=Университет]университета[/url][/color] перестал выходить на связь.", GROUP:GROUPS.NOTES},
		{NAME:"Записка 3", CLASS:CLASSES.ITEM, DESCRIPTION:"Дела становятся все хуже: счет смертельных случаев пошел на десятки. Все чаще встречается мнение о введении превентивных мер. Но из-за практически полного отсутствия информации о вирусе пока не понятно какие именно меры вводить и какое влияние они могут оказать на жизнь общества.\nНа работе уже начинают поговаривать об искусственном происхождении вируса.", GROUP:GROUPS.NOTES},
		{NAME:"Записка 4", CLASS:CLASSES.ITEM, DESCRIPTION:"Сегодня в научном журнале прочел препринт статьи о лабораторных исследованиях нового вируса. Автор утверждает что близок к полному секвенированию РНК вируса. Но даже из тех данных что есть уже можно сделать вывод что мы имеем дело с необычным вирусом. В статье приводятся только итоговые данные, поэтому я хочу связаться с автором и запросить полные данные.", GROUP:GROUPS.NOTES},
		{NAME:"Записка 5", CLASS:CLASSES.ITEM, DESCRIPTION:"Звонил завлаб, говорит что “сверху” пришло распоряжение предоставить данные о наших текущих исследованиях, просит завтра подготовить все необходимое по моему направлению работ. А также спросил что я знаю о связи моего проекта с Министерством Обороны. Я ответил что ничего об этом не знаю и что никогда не имел дела с госведомствами. Странно это все.", GROUP:GROUPS.NOTES},
		{NAME:"Записка 6", CLASS:CLASSES.ITEM, DESCRIPTION:"ВОЗ официально объявил это эпидемией. Да уж, это было очевидно еще месяц назад, а они только проснулись! Некоторые страны ограничили въезд на свою территорию, но похоже что поздно. Заболевшие есть уже в каждой стране с развитой системой международных пассажирских перевозок. Вчера наконец-то решился на это: попробую проверить некоторые догадки по этому вирусу у себя в лаборатории. Я уже связался с поставщиками реагентов, на этой неделе должны доставить все необходимое.", GROUP:GROUPS.NOTES},
		{NAME:"Записка 7", CLASS:CLASSES.ITEM, DESCRIPTION:"Теперь это очевидно: вирус влияет на иммунную систему человека. Но в отличие от ВИЧ делает это быстрее, и вероятно влияет на ДНК человека.\nЭто пугает. Прошло всего несколько месяцев с первого появления, а смертность от этого вируса уже превысила смертность от последствий ВИЧ за весь прошлый год. Нужно ускорить свои подпольные исследования на работе.", GROUP:GROUPS.NOTES},
		{NAME:"Записка 8", CLASS:CLASSES.ITEM, DESCRIPTION:"Завлаб застукал меня за моими подпольными исследованиями. Был скандал. Похоже я лишусь премии по итогам года и скорее всего не получу от него положительных рекомендаций в будущем. Но это не важно. Нужно закончить начатое: хоть он и заставил меня стереть все данные с рабочего сервера, но самое важное все равно архивировалось в мое личное “облако”. А вот с оборудованием ситуация хуже, дома у меня такого нет и не предвидится. Нужно искать другие варианты.", GROUP:GROUPS.NOTES},
		{NAME:"Записка 9", CLASS:CLASSES.ITEM, DESCRIPTION:"Договорился со знакомым, с которым вместе учились в университете. Он оформит меня к себе в лабораторию и не против чтобы я использовал лабораторное оборудование для своих исследований в свободное от работы время. Тем более что я пообещал ему соавторство, если все получится. А так как эта тема сейчас на первых полосах газет, то известность и признание в научном сообществе будет гарантировано.", GROUP:GROUPS.NOTES},
		{NAME:"Записка 10", CLASS:CLASSES.ITEM, DESCRIPTION:"Заканчиваю собирать вещи для переезда на съемную квартиру. Жена отказалась ехать и останется тут с детьми. Не то чтобы я сильно этому огорчился, - там у меня будет совсем мало времени на семью, так что может это и к лучшему. Да и тут они в большей безопасности, вдали от меня - все-таки придется иметь дело со смертельным вирусом, и даже соблюдая все меры предосторожности, заражение не исключено.", GROUP:GROUPS.NOTES},
		{NAME:"Записка 11", CLASS:CLASSES.ITEM, DESCRIPTION:"Неприятное открытие: оказывается на новом месте работы придется заниматься не совсем этичным (а возможно и незаконным) делом. Владелец лаборатории - фармакологическая компания проводит исследования и культивацию новых вирусов с целью быть первой в лидерах по разработке вакцин и лекарств против них. Но назад дороги нет, главное что у них есть все нужное мне оборудование (и даже больше).", GROUP:GROUPS.NOTES},
		{NAME:"Записка 12", CLASS:CLASSES.ITEM, DESCRIPTION:"Результаты не заставили себя долго ждать: сравнивая структуру РНК вируса с похожими РНК других вирусов, я нашел несколько фрагментов, в которых последовательности аминокислот совпадают почти полностью. При том что находятся эти фрагменты в вирусах разных групп. То есть я не исключаю что такое теоретически возможно эволюционным путем, но вероятность этого ничтожно мала.", GROUP:GROUPS.NOTES},
		{NAME:"Записка 13", CLASS:CLASSES.ITEM, DESCRIPTION:"Дальнейшие исследования выявили еще несколько странностей у вируса. Во-первых, некоторые аминокислоты вируса состоят из кодонов, которые мало распространены в природе, но зато широко применяются в синтезаторах ДНК и РНК. Во-вторых, не удается найти связь с вирусами природного происхождения через промежуточные виды. Опять-таки, я не утверждаю что это является доказательством искусственного происхождения, но слишком много совпадений.", GROUP:GROUPS.NOTES},
		{NAME:"Записка 14", CLASS:CLASSES.ITEM, DESCRIPTION:"Я подавлен. Случайно наткнулся на письма от того знакомого, который просил у меня помощи по механизмам связывания белковых соединений. Все это время они были папке со спамом! Возможно из-за прикрепленных файлов, не знаю.\nВ общем, в них он писал о том что проверял заразность нового (тогда еще нового) вируса на диких животных из ареала обитания в области первой вспышки заболеваний. Как он и предполагал, все они оказались практически иммунны к нему. Поэтому он решил также узнать каким образом вирус мог бы естественным путем передаться от животного к человеку, для этого ему и нужна была моя помощь. Исходя из моего ответа он сделал вывод что такая передача возможна только при непосредственном контакте с зараженным животным, а это слишком редкое явления чтобы послужить началом вспышки заражений.\nТакже он писал что поделился результатами своих исследований с ректором своего университета. На что тот обещал просмотреть их, но так и не сделал этого.\nИ еще он выражал тревогу по поводу того что я не выхожу на связь.", GROUP:GROUPS.NOTES},
		{NAME:"Записка 15", CLASS:CLASSES.ITEM, DESCRIPTION:"Снова плохие новости: сообщают о появлении нового штамма вируса с еще большей способностью к заражению и бессимптомным инкубационным периодом. Если не закрыть границы сейчас, он быстро распространится на весь мир (если уже не сделал этого). Но вряд ли правительства стран будут действовать на опережение, - бюрократия работает постфактум …", GROUP:GROUPS.NOTES},
		{NAME:"Записка 16", CLASS:CLASSES.ITEM, DESCRIPTION:"В интернете все больше теорий заговора. Одни утверждают что вирус придумали тайные элиты чтобы реализовать план “золотого миллиарда”. Другие - что это дело рук эко активистов, решивших таким образом остановить причинение вреда природе. Третие - что это неудачная разработка военных которая сбежала из лаборатории. Есть также предположения о фармкомпаниях, которые зарабатывают на вакцинах (тут я с грустью задумываюсь о своем новом месте работы).", GROUP:GROUPS.NOTES},
		{NAME:"Записка 17", CLASS:CLASSES.ITEM, DESCRIPTION:"Готовлю отчет о своих исследованиях. Разослал препринт в некоторые научные издания, но вряд ли они станут его читать - в современной науке без “имени” ты никто. Нужно бы заручиться поддержкой кого-нибудь из “светил” вирусологии. Также разослал данные некоторым знакомым, которым может быть это интересно. Может они помогут с публикацией.", GROUP:GROUPS.NOTES},
		{NAME:"Записка 18", CLASS:CLASSES.ITEM, DESCRIPTION:"Или я становлюсь параноиком, или за мной следят. Уже несколько раз замечал одну и ту же машину в разных частях города. А еще с недавнего времени начал “тормозить” интернет.\nНа отправленные материалы издательства, как я и предполагал, не отвечают. Но самое обидное что также не отвечают и знакомые, которым я их тоже отослал. Хоть бери, да выкладывай это все в открытый доступ где-нибудь на околонаучных форумах.", GROUP:GROUPS.NOTES},
		{NAME:"Записка 19", CLASS:CLASSES.ITEM, DESCRIPTION:"Тут явно что-то происходит! После работы ездил в полицию, заявил о слежке, назвал номер машины и описал ее внешний вид. По дороге домой пропала сотовая связь, дозвониться никуда не могу, мобильный интернет тоже не работает.\nПора спать, завтра поеду разбираться к оператору мобильной связи.", GROUP:GROUPS.NOTES},
		{NAME:"Документы из университета", CLASS:CLASSES.ITEM, DESCRIPTION:"Вырезки из местных газет: сообщения об участившихся обращениях жителей в медицинские учреждения с симптомами аллергических реакций, которых раньше не было; репортаж о нападениях диких лис на домашних животных; предупреждение о внеплановых учениях на соседней военной базе; сообщение о внезапной смерти от сердечного приступа заведующего местной медицинской лаборатории.\nСписок посвященных в исследование заразности вируса для животных: коллега из [color=aqua][url=Ветеринарная клиника]соседней ветклиники[/url][/color], лаборант из [color=aqua][url=Дом лаборанта]пригорода[/url][/color], [color=aqua][url=Дом соседа зоолога]сосед[/url][/color], вирусолог из другого [color=aqua][url=Дом ученого]города[/url][/color], ректор университета.\nЧеки на оплату: за приобретенные товары в магазине “Охота и рыбалка”, за транспортные расходы по доставке клеток с животными, за проживание в мотелях, за медицинские лабораторные исследования.\nПриказ ректора о расторжении трудового контракта с этим преподавателем, в связи с грубым нарушением трудовой этики.", GROUP:GROUPS.NOTES},

	{NAME:"Человек", CLASS:CLASSES.CREATURE, DESCRIPTION:"Один из немногих, кто выжил в этом мире", TYPE:TYPES.BIOLOGICAL, HEALTH:Vector2(100, 100), ATTACHMENT:["Удар"]},
		{NAME:"Удар", CLASS:CLASSES.ABILITY, DESCRIPTION:"Способность наносить удары противнику в рукопашном бою", CHANGE_HEALTH:-5},
		{NAME:"Собака", CLASS:CLASSES.CREATURE, DESCRIPTION:"Живая собака, друг человека", TYPE:TYPES.BIOLOGICAL, HEALTH:Vector2(30, 30), COST:10, ATTACHMENT:["Укус"]},
		{NAME:"Укус", CLASS:CLASSES.ABILITY, CHANGE_HEALTH:-10},
		{NAME:"Хлеб", CLASS:CLASSES.ITEM, DESCRIPTION:"Кусок хлеба", GROUP:GROUPS.FOOD, QUANTITY:1, COST:5, ATTACHMENT:["Съесть хлеб"]},
		{NAME:"Съесть хлеб", CLASS:CLASSES.ABILITY, CHANGE_HEALTH:5},
		{NAME:"Мясо", CLASS:CLASSES.ITEM, DESCRIPTION:"Кусок мяса", GROUP:GROUPS.FOOD, QUANTITY:1, COST:10, ATTACHMENT:["Съесть мясо"]},
		{NAME:"Съесть мясо", CLASS:CLASSES.ABILITY, CHANGE_HEALTH:10},
		{NAME:"Тушенка", CLASS:CLASSES.ITEM, DESCRIPTION:"Банка тушенки, срок годности не указан", GROUP:GROUPS.FOOD, QUANTITY:1, COST:10, ATTACHMENT:["Съесть тушенку"]},
		{NAME:"Съесть тушенку", CLASS:CLASSES.ABILITY, CHANGE_HEALTH:10},
		{NAME:"Нож", CLASS:CLASSES.ITEM, DESCRIPTION:"Обычный бытовой нож", COST:30, ATTACHMENT:["Удар ножом"]},
		{NAME:"Удар ножом", CLASS:CLASSES.ABILITY, CHANGE_HEALTH:-10},
		{NAME:"Топор", CLASS:CLASSES.ITEM, DESCRIPTION:"Топор дровосека", COST:50, ATTACHMENT:["Удар топором"]},
		{NAME:"Удар топором", CLASS:CLASSES.ABILITY, CHANGE_HEALTH:-20},
		{NAME:"Бензопила", CLASS:CLASSES.ITEM, DESCRIPTION:"Для работы нужен бензин", CAPACITY:Vector2(0, 1), CONSUMABLES:"Канистра с бензином", COST:150, ATTACHMENT:["Распил бензопилой"]},
		{NAME:"Распил бензопилой", CLASS:CLASSES.ABILITY, CHANGE_HEALTH:-50},
		{NAME:"Канистра с бензином", CLASS:CLASSES.ITEM, DESCRIPTION:"Используется только для хранения бензина", CAPACITY:Vector2(0, 10), COST:10},
		{NAME:"Дробовик", CLASS:CLASSES.ITEM, DESCRIPTION:"Грозное оружие на небольших дистанциях", CAPACITY:Vector2(0, 6), CONSUMABLES:"Патрон для дробовика", COST:250, ATTACHMENT:["Выстрел из дробовика"]},
		{NAME:"Выстрел из дробовика", CLASS:CLASSES.ABILITY, CHANGE_HEALTH:-50},
		{NAME:"Патрон для дробовика", CLASS:CLASSES.ITEM, DESCRIPTION:"Подходит только к дробовикам", QUANTITY:1, COST:5},
		{NAME:"Пистолет", CLASS:CLASSES.ITEM, DESCRIPTION:"Стреляет одиночными выстрелами", CAPACITY:Vector2(0, 9), CONSUMABLES:"Патрон 9 мм", COST:150, ATTACHMENT:["Выстрел из пистолета"]},
		{NAME:"Выстрел из пистолета", CLASS:CLASSES.ABILITY, CHANGE_HEALTH:-30},
		{NAME:"Патрон 9 мм", CLASS:CLASSES.ITEM, DESCRIPTION:"Подходит для пистолетов и пистолетов-пулеметов", QUANTITY:1, COST:5},
		{NAME:"Охотничья винтовка", CLASS:CLASSES.ITEM, DESCRIPTION:"Двухзарядная охотничья винтовка", CAPACITY:Vector2(0, 2), CONSUMABLES:"Патрон 7.62 мм", COST:190, ATTACHMENT:["Выстрел из винтовки"]},
		{NAME:"Выстрел из винтовки", CLASS:CLASSES.ABILITY, CHANGE_HEALTH:-40},
		{NAME:"Патрон 7.62 мм", CLASS:CLASSES.ITEM, DESCRIPTION:"Подходит для винтовок", QUANTITY:1, COST:5},
		{NAME:"Автоматическая винтовка", CLASS:CLASSES.ITEM, DESCRIPTION:"Стреляет очередью", CAPACITY:Vector2(0, 10), CONSUMABLES:"Патрон 5.56 мм (х3)", COST:320, ATTACHMENT:["Очередь из винтовки"]},
		{NAME:"Очередь из винтовки", CLASS:CLASSES.ABILITY, CHANGE_HEALTH:-90},
		{NAME:"Патрон 5.56 мм (х3)", CLASS:CLASSES.ITEM, DESCRIPTION:"Подходит для автоматических винтовок", QUANTITY:1, COST:15},
		{NAME:"Радиоприемник", CLASS:CLASSES.ITEM, DESCRIPTION:"В активированном состоянии позволяет слушать радиоэфир", CAPACITY:Vector2(0, 10), CONSUMABLES:"Аккумулятор", COST:60, ACTIVE:false, ATTACHMENT:["Прослушка радиоэфира"]},
		{NAME:"Прослушка радиоэфира", CLASS:CLASSES.ABILITY, DESCRIPTION:"Возможность прослушивать радиоэфир на разных частотах"},
		{NAME:"Аккумулятор", CLASS:CLASSES.ITEM, DESCRIPTION:"Хранит электроэнергию. Можно заряжать", CAPACITY:Vector2(0, 100), COST:50},
		{NAME:"Текст радиосигнала", CLASS:CLASSES.ITEM, DESCRIPTION:"Семья не может открыть входной люк в персональном подземном бункере"},
		{NAME:"Динамит", CLASS:CLASSES.ITEM, DESCRIPTION:"Обладает большой разрушительной силой", QUANTITY:1, COST:300, ATTACHMENT:["Взрыв динамита"]},
		{NAME:"Взрыв динамита", CLASS:CLASSES.ABILITY, CHANGE_HEALTH:-300},
	
	{NAME:"Новая способность", CLASS:CLASSES.ABILITY}, # заглушка для выбора перка
		{NAME:"Учебник по зоологии", CLASS:CLASSES.ITEM, DESCRIPTION:"Зоология изучает животных, их строение, поведение, эволюцию, а также их взаимодействие с окружающей средой", COST:100, ACTIVE:false, KNOWLEDGE:"Зоолог"},
		{NAME:"Зоркость", CLASS:CLASSES.ABILITY, DESCRIPTION:"Дает больше информации об окружающем мире", GROUP:GROUPS.PERK},
		{NAME:"Широкий кругозор", CLASS:CLASSES.ABILITY, DESCRIPTION:"Увеличивает на 1 количество событий для выбора", GROUP:GROUPS.PERK},
		{NAME:"Зоолог", CLASS:CLASSES.ABILITY, DESCRIPTION:"Дает преимущества при взаимодействии с животными", GROUP:GROUPS.PERK}]

var player: GameEntity # ссылка на сущность игрока
var notebook: GameEntity # ссылка на записную книжку
var _study: Dictionary # данные о проегрессе в изучении навыков

signal player_entities_changed
signal notebook_updated # эмитируется из player entity

func _ready() -> void:
	notebook = create_entity("Записная книжка")
	var note = create_entity("Записка 1")
	notebook.add_entity(note)
	emit_signal("notebook_updated", note) # для первичного заполнения GUI записной книжки
	Game.connect("new_character", self, "_on_new_character")

func get_base_entity(name: String) -> Dictionary: # возвращает копию словаря с базовыми данными сущности
	for entity_data in ENTITIES:
		if entity_data[NAME] == name:
			return entity_data.duplicate() # иначе будет все изменения будут происходить с дефолтными данными
	return {}

func create_entity(data, custom_attributes := {}) -> GameEntity: # создает новую сущность по имени или по словарю данных
	if data is String:
		data = get_base_entity(data)
	
	for key in custom_attributes: # добавляем/заменяем нестандартные атрибуты
		data[key] = custom_attributes[key]
	
	var new_entity = GameEntity.new(data)
	
	for attachment_name in data.get(ATTACHMENT, []): # добавляем вложенные сущности
		new_entity.add_entity(create_entity(attachment_name), true) # плюс автоматически активируем
	data.erase(ATTACHMENT) # эти данные нужны только для инициализации
	
	new_entity.connect("delete_request", self, "_on_entity_delete", [new_entity])
	new_entity.connect("entity_changed", self, "_on_entity_changed", [new_entity])
	
	return new_entity

func create_person(possible_weapons := [], health := 0) -> GameEntity: # создает сущность человека с заданным здоровьем и оружием
	if not health:
		health = 1 + randi() % 100 # здоровье от 1 до 100
	if not possible_weapons:
		possible_weapons = [{"Ничего":1}, {"Нож":0.6}, {"Топор":0.4}, {"Пистолет":0.3}, {"Охотничья винтовка":0.2}]
	
	var person_data = get_base_entity("Человек")
	person_data[HEALTH] = Vector2(health, max(health, 100))
	var person = create_entity(person_data)
	var weapon_name = randw(possible_weapons)
	
	if weapon_name != "Ничего":
		var weapon_data = get_base_entity(weapon_name)
		
		var capacity = weapon_data.get(CAPACITY)
		if capacity:
			weapon_data[CAPACITY].x = 1 + randi() % int(capacity.y) # случайное количество зарядов
		
		person.add_entity(create_entity(weapon_data), true) # сразу активируем
	
	return person

func _on_new_character(entity: GameEntity):
	_study.clear()
	player = entity
	player.set_attribute(E.NAME, "Игрок")
	_on_entity_changed(entity) # для обновления интерфейса под нового персонажа

func _on_entity_changed(entity: GameEntity):
	if player:
		if entity == player or entity.owner == player:
			emit_signal("player_entities_changed", player.get_entities()) # сигнал для элементов GUI

func _on_entity_delete(entity: GameEntity):
	if entity == player:
		Game.fail()
	if entity.owner:
		entity.owner.remove_entity(entity)

func duel(defender: GameEntity, attacker: GameEntity = player): # нападающий указан последним т.к. опционален
	Logger.info("Начинается поединок %s с %s" % [attacker.get_text(), defender.get_text()])
	var participants := [attacker, defender]
	var current := 0 # индекс в массиве для текущего участника
	
	for i in 100: # ограничиваем количество ударов чтобы не использовать бесконечный while true
		var damage_source = participants[current].get_attribute_owner(CHANGE_HEALTH)
		var damage: int = damage_source.get_attribute(CHANGE_HEALTH)
		damage_source.owner.change_attribute(CAPACITY) # расходуем заряд (если можно)
		var surplus = participants[current^1].change_attribute(HEALTH, damage, false) # меняем здоровье второго участника
		if surplus: return # любое ненулевое значение остатка означает смерть участника

		current = current^1 # меняем атакующего
	assert(true, "Количество обменов ударами в дуэли превысило допустимое значение!")

func study(knowledge: String, amount := MAX_STUDY) -> bool: # получение определенного количества знания, возвращает флаг успешного изучения
	if amount:
		var current_progress = get_study_progress(knowledge) + amount
		_study[knowledge] = current_progress
		Logger.info("Изучение %s (%d/%d)" % [knowledge, current_progress, MAX_STUDY], Logger.INGAME_EXP)
		if current_progress >= MAX_STUDY: # способность изучена
			player.add_entity(create_entity(knowledge), true)
			return true
		emit_signal("player_entities_changed", player.get_entities()) # для корректного отображения GUI
	return false

func current_study() -> GameEntity: # возвращает текущую изучаемую сущность
	for entity in player.get_entities(false, true):
		if entity.get_attribute(KNOWLEDGE):
			return entity
	return null

func get_study_progress(knowledge: String) -> int:
	return _study.get(knowledge, 0)

func get_perks_to_select() -> Array: # возвращает массив перков для выбора игроком
	var result := []
	
	for entity_data in ENTITIES:
		if entity_data.get(GROUP) == GROUPS.PERK:
			if player.find_entity(E.NAME, entity_data[NAME], true) == null: # нет среди активных
				result.append(entity_data)
	
	result.shuffle() # перемешиваем
	if result.size() > 3: # обрезаем до максимум трех на выбор
		result.resize(3)
	
	return result

func player_remains(keys:Array) -> Array: # определяет состав останков игрока исходя из переданных ключей
	if REMAINS.ONLY_NOTEBOOK in keys:
		return [notebook]
	
	var no_food = REMAINS.NO_FOOD in keys
	var no_pets = REMAINS.NO_PETS in keys
	
	var remains = player.get_entities()
	for entity in remains:
		var ability: bool = entity.get_attribute(E.CLASS) == CLASSES.ABILITY # это сопособность
		var food: bool = entity.get_attribute(E.GROUP) == GROUPS.FOOD if no_food else false # это еда (если нужно)
		var pet: bool = entity.get_attribute(E.TYPE) == TYPES.BIOLOGICAL if no_pets else false # это питомец (если нужно)
		if ability or food or pet: # убираем, если попадает хотябы в одну категорию
			remains.erase(entity)
	
	return remains

func clamp_int(value: int, min_value: int, max_value: int) -> int: # вариант clamp() для целых чисел
	if value > max_value: return max_value
	if value < min_value: return min_value
	return value

func randw(data: Array): # генератор взвешенных случайных чисел (pigzinzspace#7306 edition). Принимает массив словарей {ключ:вероятность}. Функция возвращает ключ выбранного случайного элемента. Пример использования: randw([{"Нож":0.25}, {"Пистолет":0.5}, {"Топор":1.0}]) вернет "Нож" с вероятностью 13%, "Топор" - 58% и "Пистолет" - 29% (в сумме 100%)
	var mass = 0.0
	for element in data:
		mass += element.values()[0] # считаем сумму всех весов
	
	data.shuffle() # тасуем массив
	
	var cut_off = randf() * mass # отсечка для общего веса
	var mass_total = 0.0 # вес наростающим итогом
	for element in data:
		mass_total += element.values()[0]
		if cut_off <= mass_total: # возвращаем элемент в который попал катоф при рандомном разрезании перемешанного массива
			return element.keys()[0] 

func _sort_entities(a: GameEntity, b: GameEntity) -> bool: # кастомная сортировка для массива сущностей
	return a.get_attribute(NAME) < b.get_attribute(NAME)

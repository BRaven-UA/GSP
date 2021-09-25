# Синглтон менеджер сущностей. Все операции с сущностями должны проходить через этот синглтон

extends Node


func create_entity(name: String) -> GameEntity: # создает новый экземпляр класса
	if name:
		for entity in Database.ENTITIES:
			if entity[Database.KEYS.NAME] == name:
				var new_entity: GameEntity
				
				match entity[Database.KEYS.CLASS]:
					Database.CLASSES.CREATURE:
						new_entity = GameCreature.new(entity)
					Database.CLASSES.ITEM:
						new_entity = GameItem.new(entity)
					Database.CLASSES.ABILITY:
						new_entity = GameAbility.new(entity)
				
				for owned_entity in entity[Database.ENTITIES]: # добавляем вложенные сущности
					new_entity.add_entity(create_entity(owned_entity))
				return new_entity
	
	push_warning("Сущности с именем [%s] нет в базе данных!" % name)
	print_stack()
	return null

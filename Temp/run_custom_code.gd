tool
extends EditorScript

func _run():
	test_randw()
#	print(char(9492))

func test_randw():
	randomize()
	var data := [{"Нож":0.25}, {"Пистолет":0.5}, {"Топор":1.0}]
	
	var result := {}
#	result["Пусто"] = 0
	for element in data:
		result[element.keys()[0]] = 0
	
	for i in 10000:
		result[randw(data)] += 0.01
	print(result)

func randw1(data: Array): # генератор взвешенных случайных чисел. Принимает массив словарей {ключ:вероятность}. Функция возвращает ключ выбранного случайного элемента. Пример использования: randw([{"Нож":0.25}, {"Топор":1.0}, {"Пистолет":0.5}]) вернет "Нож" с вероятностью 9%, "Топор" - 70% и "Пистолет" - 21% (в сумме 100%)
	var max_value := 0.0
	for element in data:
		max_value = max(max_value, element.values()[0]) # находим максимальную вероятность
	
	data.shuffle() # тасуем массив
	
	var cut_off = randf() * max_value # отсечка для элементов в диапазоне от 0 до максимальной вероятности
	
	for element in data:
		if cut_off <= element.values()[0]:
			return element.keys()[0] # возвращаем первый элемент с вероятностью выше отсечки

func randw2(data: Array):
#	data.sort_custom(self, "_sort_values")
	var max_value := 0.0
	for element in data:
		max_value = max(max_value, element.values()[0]) # находим максимальную вероятность

	var pool := []
	var cut_off = randf() * max_value
	for element in data:
		if cut_off <= element.values()[0]:
			pool.append(element)
#	print(cut_off, pool)
	if pool:
		var random = randi() % pool.size()
		return pool[random].keys()[0]
	return "Пусто"

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

static func _sort_values(a: Dictionary, b: Dictionary) -> bool:
	var a_value = a.values()[0]
	var b_value = b.values()[0]
	return a_value < b_value

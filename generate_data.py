"""
from pyexcel_ods import get_data


mapping_file = 'data.ods'
document = get_data(mapping_file)
mapping_dict = {'Овощи': 1,
                'Фрукты': 2,
                'Ягоды': 3,
                'Зелень': 4,
                'Грибы': 5,
                'Орехи': 6,
                'Крупы': 7,
                'Сухофрукт': 8,
                'Напитки': 9,
                'Соленья': 10}

for _, data in document.items():
    print('INSERT INTO products VALUES')
    for i, record in enumerate(data):
        print(f"({i+1}, '{record[1]}', 'Описание', 9.99, {mapping_dict.get(record[0])}),")
"""



from random import randint
import time
import random

def str_time_prop(start, end, format, prop):
    stime = time.mktime(time.strptime(start, format))
    etime = time.mktime(time.strptime(end, format))

    ptime = stime + prop * (etime - stime)

    return time.strftime(format, time.localtime(ptime))

def random_date(start, end, prop):
    return str_time_prop(start, end, '%m/%d/%Y', prop)

date_l, date_r, date_format = '10/16/2020', '11/30/2020', "'%m/%d/%Y'"
sold_date_l, sold_date_r = '11/30/2020', '12/23/2020'

# print(random_date("1/1/2008 1:30 PM", "1/1/2009 4:50 AM", random.random()))

"""
for point_sale in range(1, 19):
    for product_count in range(30):
        print(f"({randint(1, 541)},"
              f" {point_sale},"
              f" {randint(1,40)}, STR_TO_DATE('{random_date(date_l, date_r, random.random())}',{date_format})),")
"""


for i in range(1,540):
    count = randint(1,13)
    total = count * 9.99
    print(f" ({i}, {count}, {randint(1,2)}, {total},STR_TO_DATE('{random_date(sold_date_l, sold_date_r, random.random())}',{date_format})),")

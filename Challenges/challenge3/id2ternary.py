import math

id = 10816982
remainder = 0
id_ternary  = []

while id != 0:
    remainder = id % 3
    id = math.floor(id/3)
    
    if (remainder == 0):
        id_ternary.append(0)
    elif (remainder == 1):
        id_ternary.append(1)
    else:
        id_ternary.append(2)
print(''.join(map(str, id_ternary))[::-1])
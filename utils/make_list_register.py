import hashlib
import base64
import json 
Prefix = 'QN'
subscriberAccount = 'QN0000000'
number = 100000 # fixed number for create serialNumber
digit = 8
length_num = len(str(number))


# convert from number to str based on length of num
# example: 00000000 + 10 = 0000010  
def make_digit(number, digit = 0, prefix = '', ):
    if digit == 0: return prefix+str(number)
    return prefix + '0' * (digit - len(str(number))) + str(number)


with open('sub.json','w') as f:
    data = []
    for i in range(1, number):
        serialNumber = make_digit(i, digit, Prefix)
        rawString = subscriberAccount + str(len(subscriberAccount)) + str(len(serialNumber)) + serialNumber
        check = base64.b64encode(hashlib.md5(rawString).digest())
        data.append({
          'subscriberAccount': subscriberAccount,
          'serialNumber': serialNumber,
          'check': check
        })
    f.write(json.dumps({
                "devices": data
    }, indent=4 ))
    

#6001122 : test
#0602333 : test

def stdInfo(rrn):
    while len(rrn) is not 6:
        print('6자리가 아닙니다. 다시 입력해주세요.')
        rrn = input('주민등록번호 6자리를 입력하세요 : ')
        if len(rrn) is 6:
            break

    #앞 2자리 이용하여 나이 계산
    if int(rrn[:2]) < 21 and int(rrn[6]) in (3, 4) :
        biryear = 2000 + int(rrn[:2])
    else:
        biryear = 1900 + int(rrn[:2])
    #월
    birmonth = int(rrn[2:4])
    #일
    birday = int(rrn[4:6])
    #성별
    # if int(rrn[6]) == 1 or int(rrn[6]) == 3 :
    #     gen = 'male'
    # else :
    #     gen = 'female'
    return [CurYear-biryear, biryear, birmonth, birday]


CurYear = 2024
print(stdInfo(input('주민등록번호 7자리를 입력하세요 : ')))
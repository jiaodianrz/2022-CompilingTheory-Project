import sys
import enum
import copy
from ctypes import *
def read():  #Simulate scanf
    def get_numbers():
        try:
            read.s = input().split()
            read.s_len = len(read.s)
            if(read.s_len==0):get_numbers()
            read.cnt=0
            return 1
        except:
            return 0
    if not hasattr(read, 'cnt'):
        if not get_numbers():return 0
    if read.cnt==read.s_len:
        if not get_numbers():return 0
    read.cnt+=1
    return eval(read.s[read.cnt-1])
class Frame:
    def __init__(self) -> None:
        self.symTable = {}
        self.regList = [0]*100
        self.paramList = []
        self.tempFrame = None
        self.lastCall = -1
        self.returnValue = ''
class Parser:
    Type = enum.Enum('Type', ('FLAG', 'DECLI', 'DECLF', 'MOV', 'CALL', 'PARAM',
    'IF', 'GOTO', 'COM', 'NOT', 'LOAD', 'STORE', 'PRINTI', 'PRINTS', 'PRINTILN', 
    'PRINTSLN', 'PRINTSP', 'SCAND', 'SCANF', 'RETURN'))
    def __init__(self, fileName):
        self.fileName = fileName
        self.stmtList = []
        self.pc = 0
        self.len = 0
        self.flagDict = {}
        self.presentFrame = Frame()
        self.frameList = [self.presentFrame]
        self.input_list = []
    def readFile(self):
        with open(self.fileName) as f:
            lines = f.readlines()
            self.stmtList = lines
            for index, line in enumerate(self.stmtList):
                line = line.strip('\n')
                if('PRINTS' == line[0:6] or 'PRINTSLN' == line[0:8]):
                    line = line.split(' ', 1)
                else:
                    line = line.split()
                if(len(line) == 1):
                    self.flagDict[line[0][0:-1]] = index
                if line[0] == 'Main:':
                    self.pc = index
                self.stmtList[index] = line
            self.len = len(self.stmtList)
    def getType(stmt):
        type = -1
        if(len(stmt) == 1):
            type = Parser.Type['FLAG'].value
        if(stmt[0] == 'call'):
            type = Parser.Type['CALL'].value
        if(len(stmt) == 2 and stmt[0] == 'param'):
            type = Parser.Type['PARAM'].value
        if(len(stmt) == 3 and stmt[1] == '='):
            type = Parser.Type['MOV'].value
        if(len(stmt) == 2 and stmt[0] == 'DECLI'):
            type = Parser.Type['DECLI'].value
        if(len(stmt) == 2 and stmt[0] == 'DECLF'):
            type = Parser.Type['DECLF'].value
        if(len(stmt) == 5 and stmt[1] == '='):
            type = Parser.Type['COM'].value
        if(len(stmt) == 4 and stmt[0] == 'if'):
            type = Parser.Type['IF'].value
        if(len(stmt) == 2 and stmt[0] == 'goto'):
            type = Parser.Type['GOTO'].value
        if(len(stmt) == 4 and stmt[2] == 'not'):
            type = Parser.Type['NOT'].value
        if(len(stmt) == 2 and stmt[0] == 'RETURN'):
            type = Parser.Type['RETURN'].value
        if(len(stmt) == 2 and stmt[0] == 'SCAND'):
            type = Parser.Type['SCAND'].value
        if(len(stmt) == 2 and stmt[0] == 'SCANF'):
            type = Parser.Type['SCANF'].value
        if(len(stmt) == 2 and stmt[0] == 'PRINTI'):
            type = Parser.Type['PRINTI'].value
        if(len(stmt) == 2 and stmt[0] == 'PRINTS'):
            type = Parser.Type['PRINTS'].value
        if(len(stmt) == 2 and stmt[0] == 'PRINTILN'):
            type = Parser.Type['PRINTILN'].value
        if(len(stmt) == 2 and stmt[0] == 'PRINTSLN'):
            type = Parser.Type['PRINTSLN'].value
        if(len(stmt) == 2 and stmt[0] == 'PRINTSP'):
            type = Parser.Type['PRINTSP'].value
        if(len(stmt) == 6 and stmt[1] == '[' and stmt[3] == ']'):
            type = Parser.Type['STORE'].value
        if(len(stmt) == 6 and stmt[3] == '[' and stmt[5] == ']'):
            type = Parser.Type['LOAD'].value
        return type
    def getValue(self, s):
        if('%' in s):
            return self.presentFrame.symTable[s[1:]]
        elif('t' in s):
            return self.presentFrame.regList[int(s[1:])]
        elif('a' in s):
            return self.presentFrame.paramList[int(s[1:])]
        elif('.' in s):
            return float(s)
        else:
            return int(s)
    def computeExp(self, A, op, B):
        A = self.getValue(A)
        B = self.getValue(B)
        if(op == '+'):
            return A + B
        if(op == '-'):
            return A - B
        if(op == '*'):
            return A * B
        if(op == '/'):
            return A / B
        if(op == '<'):
            return A < B
        if(op == '>'):
            return A > B
        if(op == '!='):
            return A != B
        if(op == '>='):
            return A >= B
        if(op == '<='):
            return A <= B
        if(op == '=='):
            return A == B
        if(op == '&&'):
            return A and B
        if(op == '||'):
            return A or B
    def parse(self, stmt):
        type = Parser.getType(stmt)
        if(type == -1):
            print(f"Invalid TAC code: {' '.join(stmt)}")
        else:
            if(type == Parser.Type['GOTO'].value):
                if stmt[1] in self.flagDict:
                    self.pc = self.flagDict[stmt[1]]
            if(type == Parser.Type['PARAM'].value):
                pList = stmt[1].split(',')
                pList = [self.presentFrame.symTable[p[1:]] for p in pList]
                self.tempFrame = Frame()
                self.tempFrame.paramList = pList
            if(type == Parser.Type['CALL'].value):
                self.presentFrame.lastCall = self.pc
                self.pc = self.flagDict[stmt[1]]
                if(self.tempFrame == None):
                    self.tempFrame = Frame()
                self.frameList.append(self.tempFrame)
                self.presentFrame = self.frameList[-1]
                self.tempFrame = None
                if(len(stmt) == 4):
                    self.frameList[-2].returnValue = stmt[3][1:]
            if(type == Parser.Type['RETURN'].value):
                if(len(self.frameList) == 1):
                    self.pc = self.len - 1
                else:
                    self.frameList.pop()
                    pFrame = self.frameList[-1]
                    self.pc = pFrame.lastCall
                    pFrame.symTable[pFrame.returnValue] = self.getValue(stmt[1])
                    self.presentFrame = pFrame
            if(type == Parser.Type['DECLI'].value):
                symList = stmt[1].split(':')
                self.presentFrame.symTable[symList[0][1:]] = [0]*int(symList[1])
            if(type == Parser.Type['DECLF'].value):
                symList = stmt[1].split(':')
                self.presentFrame.symTable[symList[0][1:]] = [0.0]*int(symList[1])
            if(type == Parser.Type['MOV'].value):
                if(stmt[0][0] == 't'):
                    self.presentFrame.regList[int(stmt[0][1:])] = self.getValue(stmt[2])
                else:
                    self.presentFrame.symTable[stmt[0][1:]] = self.getValue(stmt[2])
            if(type == Parser.Type['COM'].value):
                index = int(stmt[0][1:])
                self.presentFrame.regList[index] = self.computeExp(stmt[2], stmt[3], stmt[4])
            if(type == Parser.Type['NOT'].value):
                index1 = int(stmt[0][1:])
                index2 = int(stmt[3][1:])
                self.presentFrame.regList[index1] = not self.presentFrame.regList[index2]
            if(type == Parser.Type['IF'].value):
                if(self.presentFrame.regList[int(stmt[1][1:])]):
                    self.pc = self.flagDict[stmt[3]]
            if(type == Parser.Type['PRINTS'].value):
                print(stmt[1].strip('\"'), end = "")
            if(type == Parser.Type['PRINTI'].value):
                print(self.presentFrame.symTable[stmt[1][1:]], end = "")
            if(type == Parser.Type['PRINTSLN'].value):
                print(stmt[1].strip('\"'))
            if(type == Parser.Type['PRINTILN'].value):
                print(self.presentFrame.symTable[stmt[1][1:]])
            if(type == Parser.Type['PRINTSP'].value):
                spList = stmt[1].split('-')
                value = self.presentFrame.symTable[spList[1][1:]]
                evalString = 'print("%'
                evalString = evalString + str(spList[0]) + 'd" % value, end = "")'
                eval(evalString)
            if(type == Parser.Type['SCAND'].value):
                plist = stmt[1].split(',')
                for p in plist:
                    self.presentFrame.symTable[p[1:]] = read()
            if(type == Parser.Type['SCANF'].value):
                plist = stmt[1].split(',')
                for p in plist:
                    self.presentFrame.symTable[p[1:]] = read()
            if(type == Parser.Type['STORE'].value): #%x [ t1 ] = 3 or %a
                index = self.getValue(stmt[2])
                self.presentFrame.symTable[stmt[0][1:]][int(index)] = self.getValue(stmt[5])
            if(type == Parser.Type['LOAD'].value): # t1 = %x [ t2 ]
                index = self.getValue(stmt[4])
                self.presentFrame.regList[int(stmt[0][1:])] = self.presentFrame.symTable[stmt[2][1:]][int(index)]
    def interpret(self):
        while(self.pc < self.len):
            # print(' '.join(self.stmtList[self.pc]))
            self.parse(self.stmtList[self.pc])
            self.pc += 1
if __name__=="__main__":
    fileName = str(sys.argv[1])
    ps = Parser(fileName)
    ps.readFile()
    ps.interpret()

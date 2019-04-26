SHELL := /bin/bash
MV := mv
RM := rm -f
CXX   := g++
CXXFLAGS := -g 
INCLUDES := -I/usr/local/mysql/include
LIBDIRS  :=-L/usr/local/mysql/lib
LINK     :=-lmysqlclient
BIN      := ./
SOURCES  := *.cpp 
PROGRAM  :=c_mysql_api.o

${PROGRAM} : ${SOURCES}
	$(CXX) ${CXXFLAGS}  ${SOURCES} -o ${PROGRAM}  ${LIBDIRS} ${INCLUDES}  ${LINK} 
	chmod +x ${PROGRAM}
clean :
	-${RM} ${BIN}/${PROGRAM}
	-${RM} *.o
install :
	-${MV} ${PROGRAM} ${BIN}

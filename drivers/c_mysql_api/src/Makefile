SHELL := /bin/bash
MV := mv
RM := rm -f
CXX   := g++
CXXFLAGS := -g 
INCLUDES := -I/docker-build/mysql/include
LIBDIRS  :=-L/docker-build/mysql/lib
LINK     :=-lmysqlclient
BIN      := .
SOURCES  := *.cpp 
PROGRAM  :=c_mysql_api.o

${PROGRAM} : ${SOURCES}
	$(CXX) ${CXXFLAGS}  ${SOURCES} -o ${PROGRAM}  ${LIBDIRS} ${INCLUDES}  ${LINK} 
	chmod +x ${PROGRAM}
clean :
	-${RM} *.o
install :
	-chmod +x ${BIN}/${PROGRAM}

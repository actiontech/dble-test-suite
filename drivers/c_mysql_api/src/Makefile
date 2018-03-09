SHELL := /bin/bash
MV := mv
RM := rm -f
CXX   := g++
CXXFLAGS := -g 
INCLUDES := -I/opt/mysql/include
LIBDIRS  :=-L/opt/mysql/lib
LINK     :=-lmysqlclient
BIN      := ../../c
SOURCES  := *.cpp 
PROGRAM  :=c_mysql_api.o

${PROGRAM} : ${SOURCES}
	$(CXX) ${CXXFLAGS}  ${SOURCES} -o ${PROGRAM}  ${LIBDIRS} ${INCLUDES}  ${LINK} 
	chmod +x ${PROGRAM}
clean :
	-${RM} ${BIN}/${PROGRAM}
	-${RM} *.o
install :
    -${RM} ${BIN}/${PROGRAM}
    -${MV} ${PROGRAM} ${BIN}

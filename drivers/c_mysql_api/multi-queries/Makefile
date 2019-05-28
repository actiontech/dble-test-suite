SHELL := /bin/bash
RM := rm -f
CXX   := g++
CXXFLAGS := -g
INCLUDES := -I/usr/local/mysql/include
LIBDIRS  :=-L/usr/local/mysql/lib
LINK     :=-lmysqlclient
BIN      := .
SOURCES  := *.cpp
PROGRAM  :=multiQuery.o

${PROGRAM} : ${SOURCES}
	$(CXX) ${CXXFLAGS} -o ${PROGRAM}  ${LIBDIRS} ${INCLUDES}  ${LINK}  ${SOURCES}
clean :
	-${RM} ${BIN}/${PROGRAM}
install :
	-chmod +x ${BIN}/${PROGRAM}
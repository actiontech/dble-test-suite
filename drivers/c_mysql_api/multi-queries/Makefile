SHELL := /bin/bash
RM := rm -f
CXX   := g++
CXXFLAGS := -g
INCLUDES := -I/docker-build/mysql/include
LIBDIRS  :=-L/docker-build/mysql/lib
LINK     :=-lmysqlclient
BIN      := .
SOURCES  := *.cpp
PROGRAM  :=multiQuery.o

${PROGRAM} : ${SOURCES}
	$(CXX) ${CXXFLAGS} ${SOURCES} -o ${PROGRAM}  ${LIBDIRS} ${INCLUDES}  ${LINK}
clean :
	-${RM} ${BIN}/${PROGRAM}
install :
	-chmod +x ${BIN}/${PROGRAM}
CXX = g++
CXXFLAGS = -I../Components/MotorBridgeComponent/include \
           -I/home/chumnap/fprime/build-fprime-automatic-native/Autogen/include \
           -std=c++17

SRC = src/main.cpp ../Components/MotorBridgeComponent/src/Components/MotorBridgeComponentAc.cpp
OBJ = $(SRC:.cpp=.o)
TARGET = test_motorbridge

all: $(TARGET)

$(TARGET): $(SRC)
	$(CXX) $(CXXFLAGS) $(SRC) -o $(TARGET)

clean:
	rm -f $(TARGET) $(OBJ)

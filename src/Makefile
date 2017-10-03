DRY = ../dry

include $(DRY)/predefine.mk

all: $(SOURCES) gui.py
	make -C $(DRY)
	$(PYTHON3) main.py

include $(DRY)/postdefine.mk

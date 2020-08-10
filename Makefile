MODULE_NAME=lcdi2c
MODULE_VERSION=1.1.0

DKMS       := $(shell which dkms)
PWD        := $(shell pwd)
KVERSION   := $(shell uname -r)
KERNEL_DIR  = /usr/src/linux-headers-$(KVERSION)/
MODULE_DIR  = /lib/modules/$(KVERSION)



ifneq ($(DKMS),)
MODULE_INSTALLED := $(shel dkms status $(MODULE_NAME))
else
MODULE_INSTALLED =
endif

ccflags-y   += -O2 -I$(PWD) -DVERSION="$(MODULE_VERSION)"

obj-m += $(MODULE_NAME).o
$(MODULE_NAME)-objs := hd4470.o lcdi2c_main.o


all:
	make -C $(KERNEL_DIR) M=$(PWD) modules


clean:
	make -C $(KERNEL_DIR) M=$(PWD) clean


ifeq ($(DKMS),)
install: $(MODULE_NAME).ko
	cp $(MODULE_NAME).ko $(MODULE_DIR)/kernel/drivers/auxdisplay
	depmod

uninstall:
	rm -f $(MODULE_DIR)/kernel/drivers/auxdisplay/$(MODULE_NAME).ko

else
install: $(MODULE_NAME).ko
ifneq ($(MODULE_INSTALLED),)
	@echo Module $(MODULE_NAME) is installed, uninstalling it first
	@make uninstall -m $(MODULE_NAME) -v $(MODULE_VERSION) --all
endif
	@dkms install -m $(MODULE_NAME) -v $(MODULE_VERSION)


uninstall:
ifneq ($(MODULE_INSTALLED),)
	dkms remove -m $(MODULE_NAME) -v $(MODULE_VERSION) --all
	rm -rf /usr/src/$(MODULE_NAME)-$(MODULE_VERSION)
endif

endif


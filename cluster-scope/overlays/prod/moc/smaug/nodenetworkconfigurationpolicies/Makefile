INTERFACES = \
  eno1 \
  enp4s0f0np0 \
  enp5s0f0np0 \
  enp65s0f0np0 \
  enp65s0f1np1

CONFIGS = \
	  $(patsubst %,iface-%-vlan210.yaml,$(INTERFACES)) \
	  $(patsubst %,iface-%-vlan211.yaml,$(INTERFACES))

all: $(CONFIGS)

iface-%-vlan210.yaml: template/iface-vlan210.yaml
	iface=$$(cut -f2 -d- <<<"$@"); \
	      sed -e "s/{primary}/$$iface/g" $< > $@ || { rm -f $@; exit 1; }

iface-%-vlan211.yaml: templates/iface-vlan211.yaml
	iface=$$(cut -f2 -d- <<<"$@"); \
	      sed -e "s/{primary}/$$iface/g" $< > $@ || { rm -f $@; exit 1; }

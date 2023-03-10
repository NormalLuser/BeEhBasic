CA65=ca65
LD65=ld65

basic.bin: min_mon.o
	$(LD65) -Ln L -o basic.bin \
		-C basic.cfg \
		min_mon.o

min_mon.o: min_mon.s basic.s
	$(CA65) -g --cpu 65C02 --debug-info --feature labels_without_colons min_mon.s

clean:
	rm -f min_mon.o basic.bin


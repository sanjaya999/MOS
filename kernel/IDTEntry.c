
#include "include/types.h"

struct idt_entry {
    uint16_t address_low;
    uint16_t  code_segment;
    uint8_t  zero;
    uint8_t  flags;
    uint16_t address_high;

}__attribute__((packed)); //remove padding placed by compiler for optimization

struct idt_ptr {
    uint16_t limit;
    uint32_t base;
}__attribute__((packed));

#define IDT_SIZE 256
struct idt_entry idt[IDT_SIZE];
struct idt_ptr idtp;

                    //interrupt number, address of the handler, code segment selector, flags
void idt_set_gate(uint8_t num, uint32_t base, uint16_t sel, uint8_t flags){
    idt[num].address_low = base & 0xFFFF; //111111111111111 -> 16 bits
    idt[num].address_high = (base >> 16) & 0xFFFF; //??
    idt[num].code_segment = sel;
    idt[num].zero = 0;
    idt[num].flags = flags;
}


void idt_install(){
    idtp.limit = (sizeof(struct idt_entry) * IDT_SIZE) - 1;
    idtp.base = (uint32_t)&idt;

    //clear out the entire IDT
    for(int i = 0; i < IDT_SIZE; i++){
        idt_set_gate(i, 0, 0, 0);
    }

    extern void idt_load();
    idt_load();
}
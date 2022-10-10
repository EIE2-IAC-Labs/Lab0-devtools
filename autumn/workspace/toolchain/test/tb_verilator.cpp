/*
    Author:     James Nock (jpnock/jpn119)
    Date:       2022/09/13
    Sources:    https://zipcpu.com/blog/2017/06/21/looking-at-verilator.html
*/

#include <stdlib.h>
#include <stdio.h>
#include <string>
#include <iostream>
#include <fstream>
#include <execinfo.h>
#include <signal.h>

#include "verilated.h"
#include "verilated_vcd_c.h"

// Your module header which can be found in the obj_dir directory after compiling
// your SystemVerilog HDL with Verilator.
#include "Vmod_test.h"

#define MAX_TICKS 5

class TB
{
public:
    uint64_t m_tickcount;
    VerilatedVcdC *m_trace;
    Vmod_test *m_core;

    TB()
    {
        // According to the Verilator spec, you *must* call
        // traceEverOn before calling any of the tracing functions
        // within Verilator.
        Verilated::traceEverOn(true);
        m_core = new Vmod_test;
    }

    // Open/create a trace file
    virtual void opentrace(const char *vcdname)
    {
        if (!m_trace)
        {
            m_trace = new VerilatedVcdC;
            m_core->trace(m_trace, 99);
            m_trace->open(vcdname);
        }
    }

    // Close a trace file
    virtual void close(void)
    {
        if (m_trace)
        {
            m_trace->close();
            m_trace = NULL;
        }
    }

    // Sends a synchronous reset pulse.
    virtual void reset(void)
    {
        m_core->rst_i = 1;
        this->tick();
        m_core->rst_i = 0;
    }

    // Steps the simulation and clock.
    virtual void tick(void)
    {
        // Make sure the tickcount is greater than zero before
        // we do this
        m_tickcount++;

        // Allow any combinatorial logic to settle before we tick
        // the clock.  This becomes necessary in the case where
        // we may have modified or adjusted the inputs prior to
        // coming into here, since we need all combinatorial logic
        // to be settled before we call for a clock tick.
        //
        m_core->clk_i = 0;
        m_core->eval();

        //
        // Here's the new item:
        //
        //	Dump values to our trace file
        //
        if (m_trace)
            m_trace->dump(10 * m_tickcount - 2);

        // Repeat for the positive edge of the clock
        m_core->clk_i = 1;
        m_core->eval();
        if (m_trace)
            m_trace->dump(10 * m_tickcount);

        // Now the negative edge
        m_core->clk_i = 0;
        m_core->eval();
        if (m_trace)
        {
            // This portion, though, is a touch different.
            // After dumping our values as they exist on the
            // negative clock edge ...
            m_trace->dump(10 * m_tickcount + 5);
            //
            // We'll also need to make sure we flush any I/O to
            // the trace file, so that we can use the assert()
            // function between now and the next tick if we want to.
            m_trace->flush();
        }
    }

    // Returns true if $finish() has been called.
    virtual bool done(void) { return (Verilated::gotFinish()); }
};

// sigsev_handler handles any segfaults and prints a stack trace.
void sigsev_handler(int sig)
{
    void *array[10];
    size_t size;
    size = backtrace(array, 10);
    fprintf(stderr, "Error: signal %d:\n", sig);
    backtrace_symbols_fd(array, size, STDERR_FILENO);
    exit(1);
}

// simulate runs the main simulation loop
void simulate(TB *tb)
{
    CData value = 42;

    std::cout << "position\ttick\tvalue_i\tvalue_o" << std::endl;
    while (!tb->done())
    {

        tb->m_core->value_i = value;
        std::cout << "(during tick)\t" << tb->m_tickcount << "\t" << int(tb->m_core->value_i) << "\t" << int(tb->m_core->value_o) << std::endl;
        tb->tick();

        if (tb->m_tickcount > MAX_TICKS)
        {
            std::cout << "Testbench exiting after reaching MAX_TICKS" << std::endl;
            return;
        }

        std::cout << "(at +ve edge)\t" << tb->m_tickcount << "\t" << int(tb->m_core->value_i) << "\t" << int(tb->m_core->value_o) << std::endl;
        value++;
    }
}

int main(int argc, char **argv)
{
    signal(SIGSEGV, sigsev_handler);

    Verilated::commandArgs(argc, argv);

    TB *tb = new TB();
    tb->opentrace("trace.vcd");
    tb->reset();

    simulate(tb);

    tb->close();
    return 0;
}

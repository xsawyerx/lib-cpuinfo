#!/usr/bin/perl

use strict;
use warnings;
use lib 'lib';
use experimental qw< signatures >;

use Dumbbench;

use Sys::Info;
use Rex::Inventory::Proc;
use Linux::Cpuinfo;
use Linux::Info::CpuStats;
use Lib::CPUInfo qw<
    initialize
    deinitialize
    get_current_core
    get_processors_count
>;

#use Linux::Proc::Cpuinfo;
#use Proc::CPUUsage;

use constant 'MAX_RUN' => 1e3;

print STDERR "--- Counting CPUs ---\n";

{
my $bench = Dumbbench->new(
    'target_rel_precision' => 0.005,
    'initial_runs'         => 20,
);

$bench->add_instances(
    Dumbbench::Instance::PerlSub->new(
        'name' => 'Lib::CPUInfo',
        'code' => sub {
            for ( 1 .. MAX_RUN() ) {
                initialize();
                my $count = get_processors_count();
                deinitialize();
            }
        },
    ),

    Dumbbench::Instance::PerlSub->new(
        'name' => 'Sys::Info::Device::CPU',
        'code' => sub {
            for ( 1 .. MAX_RUN() ) {
                my $info  = Sys::Info->new();
                my $cpu   = $info->device('CPU');
                my $count = $cpu->count;
            }
        },
    ),

    Dumbbench::Instance::PerlSub->new(
        'name' => 'Rex::Inventory::Proc',
        'code' => sub {
            for ( 1 .. MAX_RUN() ) {
                my $proc_i = Rex::Inventory::Proc->new;
                my $count = @{ $proc_i->get_cpus };
            }
        },
    ),

);

$bench->run;
$bench->report;
}

print STDERR "--- Getting package name ---\n";

{
my $bench = Dumbbench->new(
    'target_rel_precision' => 0.005,
    'initial_runs'         => 20,
);

$bench->add_instances(
    Dumbbench::Instance::PerlSub->new(
        'name' => 'Lib::CPUInfo',
        'code' => sub {
            for ( 1 .. MAX_RUN() ) {
                initialize();
                my $name = get_current_core()->package()->name();
                deinitialize();
            }
        },
    ),

    Dumbbench::Instance::PerlSub->new(
        'name' => 'Sys::Info::Device::CPU',
        'code' => sub {
            for ( 1 .. MAX_RUN() ) {
                my $info = Sys::Info->new();
                my $cpu  = $info->device('CPU');
                my $name = $cpu->identify();
            }
        },
    ),
);

$bench->run;
$bench->report;
}

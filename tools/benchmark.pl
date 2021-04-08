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
use CPUInfo::FFI qw<
    initialize
    deinitialize
    get_processors_count
>;

#use Linux::Proc::Cpuinfo;
#use Proc::CPUUsage;

use constant 'MAX_RUN' => 1e4;

my $bench = Dumbbench->new(
    'target_rel_precision' => 0.005,
    'initial_runs'         => 20,
);

$bench->add_instances(
    Dumbbench::Instance::PerlSub->new(
        'name' => 'CPUInfo::FFI',
        'code' => sub {
            initialize()
                or die "Cannot initialize";

            for ( 1 .. MAX_RUN() ) {
                my $count = get_processors_count();
            }

            deinitialize();
        },
    ),

    Dumbbench::Instance::PerlSub->new(
        'name' => 'Sys::Info::Device::CPU',
        'code' => sub {
            for ( 1 .. MAX_RUN() ) {
                my $info  = Sys::Info->new();
                my $cpu   = $info->device( 'CPU' );
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


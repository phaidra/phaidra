#!/usr/bin/env perl

use strict;
use warnings;
use lib('/usr/local/phaidra/phaidra-api');

# Start command line interface for application
require Mojolicious::Commands;
Mojolicious::Commands->start_app('PhaidraAPI');

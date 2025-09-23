#!/usr/bin/env perl

use strict;
use warnings;
use Data::Dumper;
use Log::Log4perl;
use LWP::UserAgent;
use JSON;
use HTTP::Request;


$ENV{MOJO_INACTIVITY_TIMEOUT} = 36000;

my $logconf = q(
  log4perl.category.MyLogger         = INFO, Screen

  log4perl.appender.Screen         = Log::Log4perl::Appender::Screen
  log4perl.appender.Screen.stderr  = 0
  log4perl.appender.Screen.layout  = Log::Log4perl::Layout::PatternLayout
  log4perl.appender.Screen.layout.ConversionPattern=%d %m%n
  log4perl.appender.Screen.utf8   = 1
);

Log::Log4perl::init( \$logconf );
my $log = Log::Log4perl::get_logger("MyLogger");

$log->info("Starting Solr field addition script");

# Get Solr configuration from environment variables
my $solr_host = $ENV{SOLR_HOST} || 'solr';
my $solr_port = $ENV{SOLR_PORT} || '8983';
my $solr_user = $ENV{SOLR_USER} || 'phaidra';
my $solr_pass = $ENV{SOLR_PASS} || 'phaidra';
my $solr_scheme = $ENV{SOLR_SCHEME} || 'http';

# Define the fields to add
my @fields_to_add = (
    {
        name => 'affiliation',
        type => 'strings',
        multiValued => 'true',
        indexed => 'true',
        stored => 'true'
    },
    {
        name => 'affiliation_id',
        type => 'strings',
        multiValued => 'true',
        indexed => 'true',
        stored => 'true'
    },
    {
        name => 'uwm_association_id',
        type => 'strings',
        multiValued => 'true',
        indexed => 'true',
        stored => 'true'
    },
    {
        name => 'extracted_text',
        type => 'text_general',
        indexed => 'true',
        stored => 'true'
    }
);

# Create LWP UserAgent
my $ua = LWP::UserAgent->new;
$ua->timeout(30);

# Function to check if field already exists
sub field_exists {
    my ($field_name, $core) = @_;
    
    my $url = "$solr_scheme://$solr_host:$solr_port/solr/$core/schema/fields/$field_name";
    my $request = HTTP::Request->new(GET => $url);
    $request->authorization_basic($solr_user, $solr_pass);
    
    my $response = $ua->request($request);
    
    if ($response->is_success) {
        return 1;
    } elsif ($response->code == 404) {
        return 0;
    } else {
        $log->error("Error checking field $field_name: " . $response->status_line);
        return -1;
    }
}

# Function to add a field to Solr schema
sub add_field {
    my ($field_config, $core) = @_;
    
    my $url = "$solr_scheme://$solr_host:$solr_port/solr/$core/schema/fields";
    my $request = HTTP::Request->new(POST => $url);
    $request->authorization_basic($solr_user, $solr_pass);
    $request->header('Content-Type' => 'application/json');
    
    my $solr_field_config = {
        "add-field" => $field_config
    };
    
    my $json = JSON->new->utf8->encode($solr_field_config);
    $request->content($json);
    
    my $response = $ua->request($request);
    
    if ($response->is_success) {
        $log->info("Successfully added field '$field_config->{name}' to core '$core'");
        return 1;
    } else {
        $log->error("Failed to add field '$field_config->{name}' to core '$core': " . $response->status_line);
        $log->error("Response: " . $response->content);
        return 0;
    }
}

# Function to process a single core
sub process_core {
    my ($core) = @_;
    
    $log->info("Processing core: $core");
    
    foreach my $field_config (@fields_to_add) {
        my $field_name = $field_config->{name};
        
        # Check if field already exists
        my $exists = field_exists($field_name, $core);
        
        if ($exists == 1) {
            $log->info("Field '$field_name' already exists in core '$core', skipping");
            next;
        } elsif ($exists == -1) {
            $log->error("Error checking field '$field_name' in core '$core', skipping");
            next;
        }
        
        # Field doesn't exist, add it
        $log->info("Adding field '$field_name' to core '$core'");
        my $success = add_field($field_config, $core);
        
        if (!$success) {
            $log->error("Failed to add field '$field_name' to core '$core'");
            return 0;
        }
    }
    
    return 1;
}

# Main execution
my $success = 1;

# Process only the main phaidra core
my @cores = ('phaidra');

foreach my $core (@cores) {
    $log->info("Processing core: $core");
    
    # Check if core exists by trying to get its schema
    my $url = "$solr_scheme://$solr_host:$solr_port/solr/$core/schema";
    my $request = HTTP::Request->new(GET => $url);
    $request->authorization_basic($solr_user, $solr_pass);
    
    my $response = $ua->request($request);
    
    if (!$response->is_success) {
        $log->warn("Core '$core' not accessible or doesn't exist, skipping");
        next;
    }
    
    my $core_success = process_core($core);
    if (!$core_success) {
        $success = 0;
    }
}

if ($success) {
    $log->info("Successfully completed adding Solr fields");
} else {
    $log->error("Some errors occurred while adding Solr fields");
    exit 1;
}

$log->info("Solr field addition script completed");

__END__

package PhaidraAPI::Controller::Alma;
use strict;
use warnings;
use v5.10;
use base 'Mojolicious::Controller';
use PhaidraAPI::Model::Alma;
use PhaidraAPI::Model::Mappings::Import::Marc;

sub search {
    my ($self) = @_;
    
    my $res = { alerts => [], status => 200 };

    my $query = $self->req->param('query');
    my $version = $self->req->param('version');
    my $operation = $self->req->param('operation');
    my $recordSchema = $self->req->param('recordSchema');
    my $maximumRecords = $self->req->param('maximumRecords');
    my $startRecord = $self->req->param('startRecord');
    
    my $alma_model = PhaidraAPI::Model::Alma->new;
    
    # Call the alma_search method from the model
    my $r = $alma_model->alma_search(
        $self, 
        $query, 
        $version, 
        $operation, 
        $recordSchema, 
        $maximumRecords, 
        $startRecord
    );

    if ($r->{status} != 200) {
        $self->render(json => $r, status => $r->{status});
        return;
    }
    
    $self->render(text => $r->{resultxml}, status => $r->{status});
}

sub get_record_json {
    my ($self) = @_;

    my $acnumber = $self->stash('acnumber');

    my $alma_model = PhaidraAPI::Model::Alma->new;
    my $r = $alma_model->alma_get_record_json($self, $acnumber);

    $self->render(json => $r, status => $r->{status});
}   

sub get_record_jsonld {
    my ($self) = @_;

    my $acnumber = $self->stash('acnumber');

    my $res = { alerts => [], status => 200 };

    my $alma_model = PhaidraAPI::Model::Alma->new;
    my $r = $alma_model->alma_get_record_json($self, $acnumber);

    if ($r->{status} != 200) {
        $self->render(json => $r, status => $r->{status});
        return;
    }

    my $marcjson = $r->{json};

    my $mappings_model = PhaidraAPI::Model::Mappings::Import::Marc->new;
    my $mappingresult = $mappings_model->get_jsonld($self, $marcjson);

    $self->render(json => $mappingresult, status => $mappingresult->{status}); 
}
1;
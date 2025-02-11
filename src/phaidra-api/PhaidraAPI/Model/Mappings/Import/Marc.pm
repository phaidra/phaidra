package PhaidraAPI::Model::Mappings::Import::Marc;    

use strict;
use warnings;
use v5.10;
use utf8;
use Switch;
use base qw/Mojo::Base/;

sub get_jsonld {
    my $self = shift;
    my $marcjson = shift;

    my $res = {alerts => [], status => 200};
    
    my $jsonld = {};

    # Get the primary language for the record
    my $primary_language = _determine_language($marcjson);

    # Process datafields
    if (exists $marcjson->{datafield}) {
        foreach my $field (@{$marcjson->{datafield}}) {
            my $tag = $field->{'@tag'};
            
            # Title mapping (245)
            if ($tag eq '245') {
                $jsonld->{'dce:title'} = [];
                my $title = {
                    '@type' => 'bf:Title',
                    'bf:mainTitle' => []
                };
                
                foreach my $subfield (@{_ensure_array($field->{subfield})}) {
                    if ($subfield->{'@code'} eq 'a') {
                        my $main_title = { '@value' => $subfield->{'#text'} };
                        $main_title->{'@language'} = $primary_language if defined $primary_language;
                        push @{$title->{'bf:mainTitle'}}, $main_title;
                    }
                    elsif ($subfield->{'@code'} eq 'b') {
                        $title->{'bf:subtitle'} //= [];
                        my $subtitle = { '@value' => $subfield->{'#text'} };
                        $subtitle->{'@language'} = $primary_language if defined $primary_language;
                        push @{$title->{'bf:subtitle'}}, $subtitle;
                    }
                }
                
                push @{$jsonld->{'dce:title'}}, $title;
            }
            
            # Language mapping (041)
            elsif ($tag eq '041') {
                $jsonld->{'dcterms:language'} = [];
                foreach my $subfield (@{_ensure_array($field->{subfield})}) {
                    if ($subfield->{'@code'} eq 'a') {
                        push @{$jsonld->{'dcterms:language'}}, $subfield->{'#text'};
                    }
                }
            }
            
            # Subject mapping (689)
            elsif ($tag eq '689') {
                $jsonld->{'dcterms:subject'} //= [];
                my $subject = {
                    '@type' => 'skos:Concept',
                    'skos:prefLabel' => []
                };
                
                foreach my $subfield (@{_ensure_array($field->{subfield})}) {
                    if ($subfield->{'@code'} eq 'a') {
                        my $label = { '@value' => $subfield->{'#text'} };
                        $label->{'@language'} = $primary_language if defined $primary_language;
                        push @{$subject->{'skos:prefLabel'}}, $label;
                    }
                    elsif ($subfield->{'@code'} eq '0' && $subfield->{'#text'} =~ /\(DE-588\)(.+)/) {
                        $subject->{'skos:exactMatch'} = ["http://d-nb.info/gnd/$1"];
                    }
                }
                
                push @{$jsonld->{'dcterms:subject'}}, $subject;
            }

            # Keywords mapping (65X)
            elsif ($tag =~ /^65\d$/) {
                $jsonld->{'dce:subject'} //= [];
                my $keyword = {
                    '@type' => 'skos:Concept',
                    'skos:prefLabel' => []
                };

                foreach my $subfield (@{_ensure_array($field->{subfield})}) {
                    if ($subfield->{'@code'} eq 'a') {
                        my $label = { '@value' => $subfield->{'#text'} };
                        $label->{'@language'} = $primary_language if defined $primary_language;
                        push @{$keyword->{'skos:prefLabel'}}, $label;
                    }
                }

                push @{$jsonld->{'dce:subject'}}, $keyword;
            }

            # Description/Abstract mapping (520)
            elsif ($tag eq '520') {
                $jsonld->{'bf:note'} //= [];
                foreach my $subfield (@{_ensure_array($field->{subfield})}) {
                    if ($subfield->{'@code'} eq 'a') {
                        my $note_text = $subfield->{'#text'};
                        my $note_language;
                        
                        if ($note_text =~ s/^([a-z]{3}):\s*//i) {
                            $note_language = lc($1);
                        } else {
                            $note_language = $primary_language if defined $primary_language;
                        }
                        
                        my $note = {
                            '@type' => 'bf:Summary',
                            'skos:prefLabel' => [{
                                '@value' => $note_text
                            }]
                        };
                        $note->{'skos:prefLabel'}[0]{'@language'} = $note_language if defined $note_language;
                        push @{$jsonld->{'bf:note'}}, $note;
                    }
                }
            }

            # Publication info mapping (264)
            elsif ($tag eq '264') {
                $jsonld->{'bf:provisionActivity'} //= [];
                my $provision = {
                    '@type' => 'bf:Publication'
                };

                foreach my $subfield (@{_ensure_array($field->{subfield})}) {
                    if ($subfield->{'@code'} eq 'a') {
                        $provision->{'bf:place'} //= [];
                        push @{$provision->{'bf:place'}}, {
                            '@type' => 'schema:Place',
                            'skos:prefLabel' => [{
                                '@value' => $subfield->{'#text'},
                                '@language' => $primary_language
                            }]
                        };
                    }
                    elsif ($subfield->{'@code'} eq 'b') {
                        $provision->{'bf:agent'} //= [];
                        push @{$provision->{'bf:agent'}}, {
                            '@type' => 'schema:Organization',
                            'schema:name' => [{
                                '@value' => $subfield->{'#text'},
                                '@language' => $primary_language
                            }]
                        };
                    }
                    elsif ($subfield->{'@code'} eq 'c') {
                        $provision->{'bf:date'} = [$subfield->{'#text'}];
                    }
                }

                push @{$jsonld->{'bf:provisionActivity'}}, $provision;
            }

            # Physical description mapping (300)
            elsif ($tag eq '300') {
                foreach my $subfield (@{_ensure_array($field->{subfield})}) {
                    if ($subfield->{'@code'} eq 'a') {
                        $jsonld->{'rdau:P60550'} //= [];
                        push @{$jsonld->{'rdau:P60550'}}, {
                            '@value' => $subfield->{'#text'},
                            '@language' => $primary_language
                        };
                    }
                }
            }

            # Series statement mapping (490)
            elsif ($tag eq '490') {
                $jsonld->{'rdau:P60193'} //= [];
                my $series = {
                    '@type' => 'schema:CreativeWork',
                    'dce:title' => []
                };

                foreach my $subfield (@{_ensure_array($field->{subfield})}) {
                    if ($subfield->{'@code'} eq 'a') {
                        push @{$series->{'dce:title'}}, {
                            '@type' => 'bf:Title',
                            'bf:mainTitle' => [{
                                '@value' => $subfield->{'#text'},
                                '@language' => $primary_language
                            }]
                        };
                    }
                    elsif ($subfield->{'@code'} eq 'v') {
                        $series->{'bibo:volume'} = [$subfield->{'#text'}];
                    }
                }

                push @{$jsonld->{'rdau:P60193'}}, $series;
            }

            # Identifier mapping (009, 020, 024)
            if ($tag eq '009') {
                $jsonld->{'rdam:P30004'} = [{
                    '@type' => 'phaidra:acnumber',
                    '@value' => $field->{subfield}{'#text'}
                }];
            }
            elsif ($tag eq '020') {
                foreach my $subfield (@{_ensure_array($field->{subfield})}) {
                    if ($subfield->{'@code'} eq 'a') {
                        $jsonld->{'rdam:P30004'} = [{
                            '@type' => 'ids:isbn',
                            '@value' => $subfield->{'#text'}
                        }];
                    }
                }
            }
            elsif ($tag eq '024') {
                my $identifier = {};
                foreach my $subfield (@{_ensure_array($field->{subfield})}) {
                    if ($subfield->{'@code'} eq 'a') {
                        $identifier->{'@value'} = $subfield->{'#text'};
                    }
                    elsif ($subfield->{'@code'} eq '2') {
                        $identifier->{'@type'} = "ids:" . $subfield->{'#text'};
                    }
                }
                if ($identifier->{'@value'} && $identifier->{'@type'}) {
                    $jsonld->{'rdam:P30004'} //= [];
                    push @{$jsonld->{'rdam:P30004'}}, $identifier;
                }
            }

            # Rights mapping (540)
            elsif ($tag eq '540') {
                foreach my $subfield (@{_ensure_array($field->{subfield})}) {
                    if ($subfield->{'@code'} eq 'f') {
                        $jsonld->{'edm:rights'} = [$subfield->{'#text'}];
                    }
                }
            }

            # Note mapping (500, 546)
            elsif ($tag eq '500' || $tag eq '546') {
                $jsonld->{'bf:note'} //= [];
                foreach my $subfield (@{_ensure_array($field->{subfield})}) {
                    if ($subfield->{'@code'} eq 'a') {
                        push @{$jsonld->{'bf:note'}}, {
                            '@type' => 'phaidra:Remark',
                            'skos:prefLabel' => [{
                                '@value' => $subfield->{'#text'},
                                '@language' => $primary_language
                            }]
                        };
                    }
                }
            }

            # Role mapping (100, 700, 710)
            elsif ($tag eq '100' || $tag eq '700') {
                $jsonld->{'role:aut'} //= [];
                my $entity = {
                    '@type' => 'schema:Person',
                    'schema:familyName' => [],
                    'schema:givenName' => []
                };
                foreach my $subfield (@{_ensure_array($field->{subfield})}) {
                    if ($subfield->{'@code'} eq 'a') {
                        my ($family_name, $given_name) = split /, /, $subfield->{'#text'}, 2;
                        push @{$entity->{'schema:familyName'}}, {
                            '@value' => $family_name,
                            '@language' => $primary_language
                        };
                        push @{$entity->{'schema:givenName'}}, {
                            '@value' => $given_name,
                            '@language' => $primary_language
                        } if defined $given_name;
                    }
                }
                push @{$jsonld->{'role:aut'}}, $entity;
            }
            elsif ($tag eq '710') {
                $jsonld->{'role:aut'} //= [];
                my $entity = {
                    '@type' => 'schema:Organization',
                    'schema:name' => []
                };
                foreach my $subfield (@{_ensure_array($field->{subfield})}) {
                    if ($subfield->{'@code'} eq 'a') {
                        push @{$entity->{'schema:name'}}, {
                            '@value' => $subfield->{'#text'},
                            '@language' => $primary_language
                        };
                    }
                    elsif ($subfield->{'@code'} eq '4') {
                        $entity->{'role'} = $subfield->{'#text'};
                    }
                }
                push @{$jsonld->{'role:aut'}}, $entity;
            }
        }
    }

    $res->{jsonld} = $jsonld;
    $res->{status} = 200;

    return $res;
}

# Helper function to ensure subfield is always an array
sub _ensure_array {
    my $subfield = shift;
    return ref($subfield) eq 'ARRAY' ? $subfield : [$subfield];
}

 # Helper function to determine language from MARC fields
sub _determine_language {
    my ($marcjson) = @_;
    
    # First try 041$a
    if (exists $marcjson->{datafield}) {
        foreach my $field (@{$marcjson->{datafield}}) {
            if ($field->{'@tag'} eq '041') {
                foreach my $subfield (@{_ensure_array($field->{subfield})}) {
                    if ($subfield->{'@code'} eq 'a') {
                        return lc($subfield->{'#text'});
                    }
                }
            }
        }
    }
    
    # If no 041, try 008 positions 35-37
    if (exists $marcjson->{controlfield}) {
        foreach my $field (@{$marcjson->{controlfield}}) {
            if ($field->{'@tag'} eq '008') {
                my $text = $field->{'#text'};
                if (length($text) >= 38) {
                    my $lang = substr($text, 35, 3);
                    return lc($lang) if $lang =~ /[a-z]{3}/i;
                }
            }
        }
    }
    
    return undef; # undefined if no language found
}

1;
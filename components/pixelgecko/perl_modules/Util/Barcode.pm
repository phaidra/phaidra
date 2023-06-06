#!/usr/bin/perl

package Util::Barcode;

# see Business::Barcode::EAN13;

__PACKAGE__->test() unless caller();

sub test
{
  my @test_codes=
  (
    [ '4006381333931', 'see https://en.wikipedia.org/wiki/International_Article_Number#Calculation_of_checksum_digit' ],
    [ '4006381333937', 'invalid ean13 code for testing', ],
  );

  foreach my $x (@test_codes)
  {
    my ($code, $note)= @$x;
    my $type= validate($code);
    print "validate: type=[$type] code=[$code] note=[$note]\n";
  }
}

sub validate
{
  my $code= shift;

  # print __LINE__, " code=[$code]\n";
  my @digits= split ('', $code);

  my $scheme;
     if ($#digits eq 12) { $scheme= 'EAN13'; }
  elsif ($#digits eq 11) { $scheme= 'UPC'; }
  else { return undef; }

  my $weight= 3;
  my $sum= 0;
  for (my $i= $#digits-1; $i >= 0; $i--)
  {
    $sum += $digits[$i] * $weight;
    $weight= ($weight == 3) ? 1 : 3;
  }
  my $mod= $sum % 10;
  my $check_digit= 10-$mod;
  # print __LINE__, " sum=[$sum] mod=[$mod] check_digit=[$check_digit]\n";

  $digits[$#digits]= $check_digit;
  my $checked_code= join ('', @digits);
  my $valid= ($code eq $checked_code) ? 1 : 0;
  # print __LINE__, " checked_code=[$checked_code] valid=[$valid]\n";

  return ($valid) ? $scheme : undef;
}

1;

use strict;
use warnings;
package App::bovespa;

use HTML::TreeBuilder;
use LWP::UserAgent;

# TODO = multiple providers
#my $url = "https://br.financas.yahoo.com/q?s=PETR4.SA";

my $agent_string = "Mozilla/5.0 (Windows NT 6.3; rv:36.0) Gecko/20100101 Firefox/36.0";

sub new {
    my ( $class ) = @_;

    bless {
    }, $class;
}

sub stock {
    my ( $self, $stock ) = @_;

    return $self->yahoo( $stock );

}

sub yahoo {
    my ( $self, $stock ) = @_;

    my $url = "https://br.financas.yahoo.com/q?s=";
    $stock = uc $stock . ".sa";

    my $ua = LWP::UserAgent->new();
    $ua->ssl_opts( verify_hostname => 0 );
    $ua->timeout( 10 );

    my $response = $ua->get( $url . $stock );
    my $raw_html;
    if ( $response->is_success ){
        $raw_html = $response->decoded_content;
    }else{
        die $response->status_line;
    }

    my $tree = HTML::TreeBuilder->new();
    $tree->parse( $raw_html );

    for ( $tree->find_by_attribute('id', "yfs_l84_". lc $stock )){
        return join "", grep { ref $_ ne "SCALAR" } $_->content_list;
    }
}



1;

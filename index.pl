#!/usr/bin/perl -T
#
# R.M. Loveland
# loveland[dot]richard[at]gmail.com
#
# Thu Jul  2 15:55:56 2009
#
#          $$    $$
#  \*\*\   \*    \*
#  \*\*   \*    \*
#  \*\*  \*    \*
#  \*\* \*   \*
#  \*\*    \*
#  \*\*  \*
#  \*\*\*
#  \*\*
#  \*\*
#  \*\*
#  \*\*
#  \*\*\*
#
#
# "There are many powers in the world, for good or for evil.
# Some are greater than I am. Against some I have not yet been measured.
# But my time is coming." --G.

use strict;
use warnings;
use CGI qw(:standard);
use CGI::Carp qw(fatalsToBrowser);
use File::stat;

my $site_name   = 'glamdring.ath.cx';
my $install_dir = 'easy_cms';
my $data_dir    = 'articles';
my $encoding    = 'utf-8';
my $css_file    = 'main.css';
my $home_page   = 'Home';
my $ext         = 'post';

my $what = param('q') || $home_page;

print header(-charset => $encoding);
print start_html(
    -title => $site_name,
    -style => {-src => "/$install_dir/css/$css_file"},
);
print div({-class => 'head'},
          h1($site_name.'&nbsp;&raquo;&nbsp;'.anglicize($what)),
          div({-class => 'navbar'},
              navbar({
                  ucfirst $home_page => "/$install_dir",
                  ucfirst $data_dir  => "/$install_dir/index.pl?q=$data_dir",
              })));
print div({-class => 'dynamic'}, show_page($what));
print end_html;

sub navbar {
    ## Hashref -> Str
    my $href = shift;
    my @elems = grep { defined $$href{$_} } keys %$href;
    my @navlinks = map { a({href => $$href{$_}}, $_) } @elems;
    my $menu = p(join ' | ', @navlinks);
    return $menu;
}

sub anglicize {
    ## Str -> Str
    my $title = shift;
    my @caps = split /-|_/, $title;
    my $legible = join( ' ', map { ucfirst $_ } @caps );
    return $legible;
}

sub untaint {
    ## Str -> Str
    my $tainted = shift;
    my ($cleansed) = ($tainted =~ /^([-\w]+)$/); ## Thanks Ovid!
    return $cleansed or die "$tainted is tainted";
    # if($tainted =~ /^([-\w]+)$/) {
    #         return $1;
    #     }
    #     else {
    #         croak "$tainted is tainted: $!";
    #     }
}

sub linkify_directory {
    ## Str -> Array
    my $what = shift;

    my @files = grep /$ext/, get_directory_listing($what);
    my @cleaned = grep !/(^\.|~$)/, map { chop_ext($_) } @files;
    my @links = map
        { a({-href => "/$install_dir/index.pl?q=$_"}, anglicize($_)) }
            @cleaned;
    return @links;
}

sub get_directory_listing {
    ## Str -> Array
    my $what = shift;
    opendir my $fh, $what or die $!;
    my @files = readdir($fh);
    close $fh;

    chdir $what or die "Couldn't chdir to $what: $!"; ## in order for -M to work
    @files = sort { -M $a cmp -M $b } grep !/(^\.|~$)/, @files;
    return @files;
}

sub txtify_file {
    ## Str -> Str
    my $what = shift;
    chdir $data_dir or die "Can't change to $data_dir: $!";
    open my $fh, '<', $what
        or die "Couldn't open $what : $!";
    my $stat = stat($fh);
    my $date = localtime($stat->mtime);
    read($fh, my $txt, -s $fh);
    close $fh;
    my $chopped = chop_ext($what);
    my $html    = br
        .hr
        .$txt
        .a({-href=>"/$install_dir/index.pl?q=$chopped"},
           em('[permalink]'));
    return $html;
}

sub show_page {
    ## Str -> Str
    my $tainted = shift;
    my $what    = untaint($tainted);
    if($what eq $data_dir) {
        my @links = grep !/$home_page/i, linkify_directory($what);
        return ul(li(\@links));
    }
    elsif($what eq $home_page) {
        my $html = txtify_file(lc "$home_page.$ext");
        return $html;
    }
    else {
        my $html = txtify_file("$what.$ext");
        return $html;
    }
}

sub chop_ext {
    ## Str -> Str
    my $arg = shift;
    $arg =~ s/\.$ext$//gi;
    return $arg;
};

__END__

=pod

=head1 NAME

Cobble: simple website management for busy people.

=head1 DESCRIPTION

Cobble is a Perl program that will let you automatically manage your
simple website. It works like this: you tell Cobble what directory
your site's pages live in, along with a few other little details like
your preferred file extensions and so forth, and it does the rest and
leaves you alone.

The default setup is very simple, but can be modified as needed. You
write your own HTML, your own CSS, and manage your own directories of
images and the like. Very little is dictated to you, which is good, as
you will probably want to change things around to suit yourself. This
is exactly as it should be.

Cobble was written with simplicity in mind, so as to be easily
modifiable. It lives in a single file; it will work on cheap shared
hosting with FTP access, as well as on a home server. It works on flat
files (no databases required) and all you need is a reasonable version
of Perl 5. No non-core Perl modules are used. Taint mode is enabled by
default for security.

=head1 BUGS AND CAVEATS

Cobble was written by an amateur, for free. It is therefore definitely
buggy, and you probably shouldn't use it at all. :-)

More seriously, its overall implementation is unsophisticated and
limited in function. The CGI portion of the code itself isn't
beautiful, nor is the code dealing with files and
directories. Subroutine names are descriptive in some places and not
in others.

Currently, Cobble needs a fair bit of fit and finish work. HTTP error
codes for non-existent pages aren't there yet, among other
things. There's still lots to do, and a lot of it can be done by
people with minimal Perl skills (which is a feature, I think).

Any offers of help, comments, advice, complaints and so on will be
appreciated.

Finally, I leave the reader with this dictionary entry
from L<http://en.wiktionary.org/wiki/cobbled>:

I<cobbled, adj>.

=over

=item 1. (of a road surface) Laid with cobbles.

=item 2. Crudely or roughly assembled; put together in an improvised
way, (as in "cobbled together")

=back

=head1 SEE ALSO

Blosxom is a simple but effective piece of blogging software written
in Perl, which served as the inspiration for Cobble.

=head1 AUTHOR

R.M. Loveland, <loveland.richard@gmail.org>

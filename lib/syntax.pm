use strict;
use warnings;

# ABSTRACT: Activate syntax extensions

package syntax;

use Data::OptList qw( mkopt );

use namespace::clean;

$Carp::Internal{ +__PACKAGE__ }++;

sub import_into {
    my ($class, $into, @args) = @_;

    my $import = mkopt \@args;

    for my $declaration (@$import) {
        my ($feature, $options) = @$declaration;

        $class->_install_feature($feature, $into, $options);
    }

    return 1;

}

sub import {
    my ($class, @args) = @_;

    my $caller = caller;

    return $class->import_into($caller, @args);
}

sub _install_feature {
    my ($class, $feature, $caller, $options) = @_;

    my $name =
        join '',
        map ucfirst,
        split /_/, $feature;

    my $file    = "Syntax/Feature/${name}.pm";
    my $package = "Syntax::Feature::${name}";

    require $file;
    return $package->install(
        into        => $caller,
        options     => $options,
        identifier  => $feature,
    );
}

1;

=method import

    syntax->import( @spec );

This method will dispatch the syntax extension setup to the specified feature
handlers for the calling package.

=method import_into

    syntax->import_into( $into, @spec );

Same as L</import>, but performs the setup in C<$into> instead of the calling
package.

=head1 SYNOPSIS

    # either
    use syntax 'foo';

    # or
    use syntax foo => { ... };

    # or
    use syntax qw( foo bar ), baz => { ... };

=head1 DESCRIPTION

This module activates community provided syntax extensions to Perl. You pass it
a feature name, and optionally a scalar with arguments, and the dispatching 
system will load and install the extension in your package.

The import arguments are parsed with L<Data::OptList>. There are no 
standardised options. Please consult the documentation for the specific syntax
feature to find out about possible configuration options.

The passed in feature names are simply transformed: C<function> becomes
L<Syntax::Feature::Function> and C<foo_bar> would become 
C<Syntax::Feature::FooBar>.

This module will also automatically enable L<strict> and L<warnings> upon
L</import>.

=head1 RECOMMENDED FEATURES

=over

=item * L<Syntax::Feature::Function>

Activates functions with parameter signatures.

=back

=head1 SEE ALSO

L<Syntax::Feature::Function>,
L<Devel::Declare>

=cut

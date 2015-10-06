package pfappserver::Form::Config::Authentication::Source::Stripe;

=head1 NAME

pfappserver::Form::Authentication::Source::Stripe

=cut

=head1 DESCRIPTION

pfappserver::Form::Authentication::Source::Stripe

=cut

use strict;
use warnings;
use HTML::FormHandler::Moose;
use pf::Authentication::Source::StripeSource;
use pf::log;
extends 'pfappserver::Form::Config::Authentication::Source::Billing';
with 'pfappserver::Base::Form::Role::Help';

has 'roles' => (
    is => 'rw',
);
# Form fields
has_field 'test_secret_key' => (
    type => 'Text'
);

has_field 'test_publishable_key' => (
    type => 'Text'
);

has_field 'live_secret_key' => (
    type => 'Text',
    required => 1
);

has_field 'live_publishable_key' => (
    type => 'Text',
    required => 1
);

has_field 'style' => (
    type    => 'Select',
    default => 'charge',
    options => [{label => 'Charge', value => 'charge'}, {label => 'Subscription', value => 'subscription'}]
);

has_block definition => (
    render_list => [qw(test_secret_key test_publishable_key live_secret_key live_publishable_key style currency test_mode)]
);

has_field 'domains' =>
  (
   type => 'Text',
   label => 'Authorized domains',
   required => 1,
   default => pf::Authentication::Source::StripeSource->meta->get_attribute('domains')->default,
   element_attr => {'placeholder' => pf::Authentication::Source::StripeSource->meta->get_attribute('domains')->default},
   element_class => ['input-xlarge'],
   tags => { after_element => \&help,
             help => 'Comma separated list of domains that will be resolve with the correct IP addresses.' },
  );

sub options_failed_payment_role {
    my $self = shift;
    my ($status, $result) = $self->form->ctx->model('Roles')->list();
    my @roles = map { $_->{name} => $_->{name} } @{$result} if ($result);
    return ( @roles);
    # $self->roles comes from pfappserver::Model::Roles
}

sub ACCEPT_CONTEXT {
    my ($self, $c, @args) = @_;
    my ($status, $roles) = $c->model('Roles')->list();
    return $self->SUPER::ACCEPT_CONTEXT($c, roles => $roles, @args);
}

=head1 AUTHOR

Inverse inc. <info@inverse.ca>

=head1 COPYRIGHT

Copyright (C) 2005-2015 Inverse inc.

=head1 LICENSE

This program is free software; you can redistribute it and::or
modify it under the terms of the GNU General Public License
as published by the Free Software Foundation; either version 2
of the License, or (at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with this program; if not, write to the Free Software
Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301,
USA.

=cut

1;

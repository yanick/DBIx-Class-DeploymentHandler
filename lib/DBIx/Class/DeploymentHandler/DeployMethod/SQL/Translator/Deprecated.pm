package DBIx::Class::DeploymentHandler::DeployMethod::SQL::Translator::Deprecated;
use Moose;

# ABSTRACT: (DEPRECATED) Use this if you are stuck in the past

use Method::Signatures::Simple;

use File::Spec::Functions;

extends 'DBIx::Class::DeploymentHandler::DeployMethod::SQL::Translator',

method _ddl_schema_consume_filenames($type, $version) {
  return [$self->_ddl_schema_produce_filename($type, $version)]
}

method _ddl_schema_produce_filename($type, $version) {
  my $filename = ref $self->schema;
  $filename =~ s/::/-/g;

  $filename = catfile(
    $self->script_directory, "$filename-$version-$type.sql"
  );

  return $filename;
}

method _ddl_schema_up_produce_filename($type, $versions, $dir) {
  my $filename = ref $self->schema;
  $filename =~ s/::/-/g;

  $filename = catfile(
    $self->script_directory, "$filename-" . join( q(-), @{$versions} ) . "-$type.sql"
  );

  return $filename;
}

method _ddl_schema_up_consume_filenames($type, $versions) {
  return [$self->_ddl_schema_up_produce_filename($type, $versions)]
}

__PACKAGE__->meta->make_immutable;

1;

# vim: ts=2 sw=2 expandtab

__END__

=head1 DESCRIPTION

All this module does is override a few parts of
L<DBIx::Class::DeployMethd::SQL::Translator> so that the files generated with
L<DBIx::Class::Schema::Versioned> will work with this out of the box.

=head1 DEPRECATED

I begrudgingly made this module (and other related modules) to keep porting
from L<DBIx::Class::Schema::Versioned> relatively simple.  I will make changes
to ensure that it works with output from L<DBIx::Class::Schema::Versioned> etc,
but I will not add any new features to it.

Once I hit major version 1 usage of this module will emit a warning.
On version 2 it will be removed entirely.

=head1 THIS SUCKS

Yeah, this old Deprecated thing is a drag.  It can't do downgrades, it can only
use a single .sql file for migrations, it has no .pl support.  You should
totally switch!  Here's how:

 my $init_part = ref $schema;
 $init_part =~ s/::/-/g;
 opendir my $dh, 'sql';
 for (readdir $dh) {
   if (/\Q$init_part\E-(.*)-(.*)(?:-(.*))?/) {
    if (defined $3) {
      cp $_, $dh->deploy_method->_ddl_schema_up_produce_filename($3, [$1, $2]);
    } else {
      cp $_, $dh->deploy_method->_ddl_schema_produce_filename($2, $1);
    }
  }
 }

=head1 OVERRIDDEN METHODS

=over

=item *

L<DBIx::Class::DeployMethod::SQL::Translator/_ddl_schema_consume_filenames>

=item *

L<DBIx::Class::DeployMethod::SQL::Translator/_ddl_schema_produce_filename>

=item *

L<DBIx::Class::DeployMethod::SQL::Translator/_ddl_schema_up_produce_filename>

=item *

L<DBIx::Class::DeployMethod::SQL::Translator/_ddl_schema_up_consume_filenames>

=back


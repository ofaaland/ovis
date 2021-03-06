package benv;

# Put needed ENVLIST here

open my $cfile, "grep '=' config.sh | sed 's/.* \\(.*\\)=.*/\\1/'|" or die;
our @BENV_LIST = <$cfile>;

chomp @BENV_LIST;

our @ISA = qw(Exporter);

sub import {
	my ($cc) = caller(0);
	my ($pkgname, @list) = @_;
	@list = @BENV_LIST if not @list;
	for my $X (@list) {
		my $str = "package $cc; use vars qw(\$$X)";
		eval $str;
		tie ${"${cc}::$X"}, benv, $X;
		# Then try getting it to test
		my $tmp = ${"${cc}::$X"};
	}
}

sub TIESCALAR {
	bless \($_[1]);
}

sub FETCH {
	my ($self) = @_;
	my $v = $ENV{$$self};
	die "ERROR: Cannot get environment variable $$self<<" if not length "$v";
	$ENV{$$self};
}

sub STORE {
	my ($self, $value) = @_;
	if (defined($value)) {
		$ENV{$$self} = $value;
	} else {
		delete $ENV{$$self};
	}
}


1;

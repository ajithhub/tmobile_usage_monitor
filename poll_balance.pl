use strict;
use warnings;
use DBI;
use Date::Parse;

use Data::Dumper;
my $dbargs = {AutoCommit => 1,
              PrintError => 1};
my $db_file = "/tmp/tmobile_module/tmobile_prepaid_usage/usage.db";

my $dbh = DBI->connect("dbi:SQLite:dbname=$db_file","","",$dbargs)
    or die $!;

use lib '/tmp/tmobile_module/Business-Billing-TMobile-USA/lib';

use Business::Billing::TMobile::USA;
use YAML;


my $ins_user_sth = $dbh->prepare('insert into users (first_name, full_name, username, is_prepaid, timestamp) values (?,?,?,?, DATETIME(\'NOW\'))');

my $ins_usage_sth = $dbh->prepare('insert into usage_history (user_id, minutes, messages, balance, expiration, timestamp) values (?,?,?,?,DATETIME(?,\'unixepoch\'), DATETIME(\'NOW\'))');

my $user_query_sth = $dbh->prepare(
      "Select id from users where username = ? and first_name = ?");

my ($username, $password) = @ARGV;

$username and $password
    or die "Need a user and password";

print YAML::Dump($username, $password);

my $account = Business::Billing::TMobile::USA->new(debug =>0);

my $user = $account->login(user => $username, password => $password)
    or die "Problem logging in";


$user->{is_prepaid} =~ /false/i
    and die "Not a prepay account";

$user_query_sth->execute($user->{user}, $user->{first_name})
    or die "Couldn't execute statement: ";

my $user_id;
$DB::single=2;
unless (($user_id) = $user_query_sth->fetchrow_array()) {

    $ins_user_sth->execute(
        $user->{first_name},
        $user->{full_name},
        $user->{user},
        ($user->{is_prepaid} =~ /true/i ? 1 : 0),
   );
    if ($dbh->err()) { die "$DBI::errstr\n";}
    $dbh->commit();

    $user_query_sth->execute($user->{user}, $user->{first_name})
        or die "Couldn't execute statement: ";
    ($user_id) = $user_query_sth->fetchrow_array()
        or die "Problem inserting";
}

printf "Go rowid %s", $user_id;


my $prepay_info = $account->get_prepay_details();

my $exp_time = Date::Parse::str2time($prepay_info->{expiration});

$ins_usage_sth->execute(
    $user_id,
    $prepay_info->{minutes},
    $prepay_info->{messages},
    $prepay_info->{balance},
    $exp_time);

if ($dbh->err()) { die "$DBI::errstr\n";}
$dbh->commit();

print YAML::Dump($user);
print YAML::Dump($prepay_info);

unit role GraphQL::Query[Str $name];
use GraphQL::Functions;
has Bool $.graphQL-query      = True;
has Str  $.graphQL-query-name = $name;

method schema {
	my $schema = "{self.graphQL-query-name}(";
	my \sig = self.signature;
	$schema ~= do for sig.params.skip.grep: *.name.substr(1) !=== "_" {
		my \def = do with .default { " = {.()}" } else {""};
		"{ .name.substr: 1 }: { .&translate-param }{ def }"
	}.join: ", ";
	$schema ~ "): {sig.returns.&translate-param}"
}

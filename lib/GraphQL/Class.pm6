my %map =
	Str 	=> "String",
	Bool	=> "Boolean",
	Int		=> "Int"
;

role GraphQL::ID {
	has $.graphQL-ID = True
}

role GraphQL::Query[Str $name] {
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
}

role GraphQL::Class {
	%map{ ::?CLASS.^name } = ::?CLASS.^name;

	method schema-Hash(--> Hash()) {
		self.^attributes.grep(*.has_accessor).map: {
			.name.substr(2) => (
				:type(.&translate-attr),
				:doc(.WHY//Str)
			).Hash
		}
	}

	method attr-schema(--> Str()) {
		my $schema ="# {self.WHY}\n";
		$schema ~="type {self.^name} \{\n";
		my %schema-hash = self.schema-Hash;
		my $attr-size = %schema-hash.keys>>.chars.max;
		my $type-size = %schema-hash.values.map(*.<type>.chars).max;
		$schema ~= do for %schema-hash.pairs {
			sprintf "\t% -*s: % -*s%s",
				$attr-size,
				.key,
				$type-size,
				.value<type>,
				(with .value<doc> {"  # {$_}"} else {""}
			)
		}.join: "\n";
		$schema ~ "\n}"
	}

	method queries {
		do for self.^methods.grep: GraphQL::Query {
			(.WHY ?? "\t# {.WHY}\n" !! "") ~ "\t{.schema}"
		}
	}

	method query-schema(--> Str()) {
		my $q = "type Query \{\n";
		$q ~= self.queries.join: "\n";
		$q ~ "\n}"
	}

	multi method schema(--> Str()) {
		(
			self.attr-schema,
			self.query-schema,
		).join: "\n"
	}
}

proto translate-attr(\attr) {
	my $name = {*};
	$name ~ ("!" if attr.required)
}

multi translate-attr(Positional \p) is default {
	"[{ translate-attr p.of }]"
}

multi translate-attr(GraphQL::ID) is default {
	"ID"
}

multi translate-attr(Attribute \attr) {
	my \name = attr.type.^name;
	do with %map{name} {
		$_
	} else {
		"String"
	}
}

multi translate-param(Mu:U) {
    fail "A method must have a return type to be used as query"
}

multi translate-param(Parameter \attr) is default {
	my $name = translate-param attr.type;
	$name ~ ("!" unless attr.optional)
}

multi translate-param(Positional \p) {
	"[{ translate-param p.of }]"
}

multi translate-param(GraphQL::ID) {
	"ID"
}

multi translate-param(\type) {
	my \name = type.^name;
	do with %map{name} {
		$_
	} else {
		"String"
	}
}

multi trait_mod:<is>(Attribute $a, :$ID!) is export {
	$a does GraphQL::ID
}

multi trait_mod:<is>(Parameter $a, :$ID!) is export {
	$a does GraphQL::ID
}

multi trait_mod:<is>(Method $a, Bool :$query!) is export {
	trait_mod:<is>($a, :query($a.name))
}

multi trait_mod:<is>(Method $a, Str :$query!) is export {
	$a does GraphQL::Query[$query]
}

sub schema(*@classes is copy --> Str()) is export {
	@classes .= unique;
	my $s = @classes.map(-> $class {
		$class.attr-schema
	}).join: "\n";
	$s ~= "\ntype Query \{\n{@classes.map({|.queries}).join: "\n"}\n\}";
	$s
}


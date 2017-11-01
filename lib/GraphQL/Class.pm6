use GraphQL::ID;
use GraphQL::Query;
use GraphQL::Functions;

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

sub schema(*@classes is copy --> Str()) is export {
	@classes .= unique;
	my $s = @classes.map(-> $class {
		$class.attr-schema
	}).join: "\n";
	$s ~= "\ntype Query \{\n{@classes.map({|.queries}).join: "\n"}\n\}";
	$s
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

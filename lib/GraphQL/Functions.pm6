use GraphQL::ID;

our %map is export =
	Str 	=> "String",
	Bool	=> "Boolean",
	Int		=> "Int"
;

proto translate-attr(\attr) is export {
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

proto translate-param($) is export {*}

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



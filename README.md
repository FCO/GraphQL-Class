# GraphQL::Class

```
$ cat test.p6
use GraphQL::Class;

#| User class
class User does GraphQL::Class {
   has UInt $.id is ID is required; #= User Id
   has Str  $.name;                 #= The user name
   has Date $.birthday;             #= The birthday of the user
   has Bool $.status;               #= Is it active?

   method listusers(::?CLASS:U: Int :$start is ID = 0, Int :$count = 1 --> Positional[User]) is query {
   }

   method user(::?CLASS:U: Int :$id! is ID --> User) is query {
   }
}
say User.new: :42id, :name<Fernando>, :status;

say User.schema
$ perl6 -Ilib test.p6
User.new(id => 42, name => "Fernando", birthday => Date, status => Bool::True)
type User {
	name    : String   # The user name
	status  : Boolean  # Is it active?
	id      : ID!      # User Id
	birthday: String   # The birthday of the user
}
type Query {
	listusers(start: Int = 0, count: Int = 1): [User]
	user(id: Int!): User
}
```

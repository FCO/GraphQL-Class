use GraphQL::Class;

#| User class
class User does GraphQL::Class {
   my ::?CLASS @users = ^10 .map: -> $id {User.new: :id($id), :name("user$id"), :status }
   has UInt $.id is ID is required; #= User Id
   has Str  $.name;                 #= The user name
   has Date $.birthday;             #= The birthday of the user
   has Bool $.status;               #= Is it active?

   method all(::?CLASS:U: Int :$start is ID = 0, Int :$count = 1 --> Array[User]) is query<listusers> {
	   @users[$start ..^ $start+$count]
   }

   method get(::?CLASS:U: Int :$id! is ID --> User) is query<user> {
	   @users[$id]
   }
}
say User.new: :42id, :name<Fernando>, :status;

say User.schema


#include <lua/lua.h>
#include <lua/lauxlib.h>
#include <lua/lualib.h>

#include <stdlib.h>
#include <stdio.h>

int main(int argc, const char** argv)
{
	lua_State* L = luaL_newstate();
	if(!L)
	{
		fprintf(stderr, "Couldn't create lua state; no mem\n");
		return EXIT_FAILURE;
	}
	
	luaL_openlibs(L);
	
	lua_checkstack(L,2);
	lua_getglobal(L,"require");
	lua_pushliteral(L, "main");
	lua_call(L,1,0);
	lua_close(L);
	return EXIT_SUCCESS;
}

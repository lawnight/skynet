#include <lua.h>
#include <lauxlib.h>

static int
traceback(lua_State *L)
{
    const char *msg = lua_tostring(L, 1);
    if (msg)
    {
        luaL_traceback(L, L, msg, 1);
    }
    else
    {
        lua_pushliteral(L, "(no error message)");
    }
    return 1;
}

static int
callc(lua_State *L)
{

    int *a = malloc(sizeof(int));
    printf("i'm c %d\n", *(a + 1));
    lua_getglobal(L, "c");

    lua_call(L, 0, 0);
    //int r = lua_call(L, 0, 0);

    luaL_error(L, "Listen error");

    return 1;
}

int main()
{
    lua_State *L = luaL_newstate();
    luaL_openlibs(L);

    // lua_newtable(L);
    // if (lua_isnumber(L, -1))

    // {
    //     printf("is num \n");
    // }

    // double a = lua_tonumber(L, -1);
    // printf("num is %d", a);

    // int type = lua_getglobal(L, "coroutine");
    // if (lua_istable(L, -1))
    // {
    //     printf("coroutine is table \n");
    // }

    // //printf("%d\n", 0);

    // lua_getfield(L, -1, "resume");

    // lua_CFunction co_resume = lua_tocfunction(L, -1);
    // if (co_resume == NULL)
    //     return luaL_error(L, "Can't get coroutine.resume");

    // lua_pushstring(L, "aaaaa");
    // lua_setglobal(L, "aaa");
    // //luaL_dostring(L, "debug.debug()");
    // printf(lua_tostring(L, -1));

    // //lua_call(L, 0, 0);
    // luaL_dostring(L, "print(\"hello\")");

    // luaL_Reg l[] = {
    //     {"callc", callc},
    // };
    // luaL_newlib(L,l,0);

    lua_pushcfunction(L, callc);
    lua_setglobal(L, "callc");

    printf("test lua_pcall---------------------------\n");
    lua_pushcfunction(L, traceback);
    // luaL_loadstring(L, " \
    // print \"i'm load string\"    \
    // ff()");

    int ret = luaL_loadfile(L, "work/test/main2.lua");

    if (ret)
    {
        printf("load file error:%s\n", lua_tostring(L, -1));
    }

    int r = lua_pcall(L, 0, 0, -2);
    //int r = lua_call(L, 0, 0);

    if (r == LUA_ERRRUN)
    {
        printf("lua error is 0000%s0000\n", lua_tostring(L, -1));
    }

    printf("all done\n");
    //getchar();
    return 0;
}

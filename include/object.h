#ifndef clox_object_h
#define clox_object_h

#include "value.h"
#include "chunk.h"
#define OBJ_TYPE(value) (AS_OBJ(value)->type)
#define IS_STRING(value) isObjType(value, OBJ_STRING)
#define AS_STRING(value) ((ObjString *)AS_OBJ(value))
#define AS_CSTRING(value) (((ObjString *)AS_OBJ(value))->chars)
#define IS_FUNCTION(value) isObjType(value, OBJ_FUNCTION)
#define AS_FUNCTION(value) ((ObjFunction *)AS_OBJ(value))
#define IS_NATIVE(value) isObjType(value, OBJ_NATIVE)
#define AS_NATIVE(value) (((ObjNative *)AS_OBJ(value))->function)
#define IS_CLOSURE(value) isObjType(value, OBJ_CLOSURE)
#define AS_CLOSURE(value) ((ObjClosure *)AS_OBJ(value))

typedef enum
{
    OBJ_STRING,
    OBJ_NATIVE,
    OBJ_FUNCTION,
    OBJ_CLOSURE,
    OBJ_UPVALUE
} ObjType;

struct Obj
{
    ObjType type;
    struct Obj *next;
};

typedef Value (*NativeFn)(int argCount, Value *args);
struct ObjNative
{
    Obj obj;
    NativeFn function;
};

typedef struct ObjUpvalue
{
    Obj obj;
    Value *location;
    Value closed;
    struct ObjUpvalue *next;
} ObjUpvalue;

struct ObjString
{
    Obj obj;
    int length;
    char *chars;
    uint32_t hash;
};

struct ObjFunction
{
    Obj obj;
    int arity;
    int upvalueCount;
    Chunk chunk;
    ObjString *name;
};

typedef struct
{
    Obj obj;
    ObjUpvalue **upvalues;
    ObjFunction *function;
    int upvalueCount;
} ObjClosure;

ObjString *copyString(const char *chars, int length);
ObjString *takeString(const char *chars, int length);
ObjString *allocateString(char *chars, int length, uint32_t hash);
void printObject(Value value);

ObjFunction *newFunction();
ObjFunction *createFunction();

ObjNative *newNative(NativeFn function);
ObjClosure *newClosure(ObjFunction *function);
ObjUpvalue *newUpvalue(Value *slot);

static inline bool isObjType(Value value, ObjType type)
{
    return IS_OBJ(value) && AS_OBJ(value)->type == type;
}

#endif
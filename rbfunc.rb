
def object_methods(obj)
        obj.methods - Object.methods
end

y = "dlsadksad"

object_methods(y).each() { |method|
        puts(method)
}

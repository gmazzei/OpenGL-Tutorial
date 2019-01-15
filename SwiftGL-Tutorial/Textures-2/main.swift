import CGLFW3
import SGLOpenGL
import SGLImage
import Darwin.C

// Window dimensions
let WIDTH:GLsizei = 800, HEIGHT:GLsizei = 600

func keyCallback(window: OpaquePointer!, key: Int32, scancode: Int32, action: Int32, mode: Int32) {
    if (key == GLFW_KEY_ESCAPE && action == GLFW_PRESS) {
        glfwSetWindowShouldClose(window, GL_TRUE)
    }
}

func main() {
    glfwInit()
    defer { glfwTerminate() }
    
    glfwWindowHint(GLFW_CONTEXT_VERSION_MAJOR, 3)
    glfwWindowHint(GLFW_CONTEXT_VERSION_MINOR, 3)
    glfwWindowHint(GLFW_OPENGL_PROFILE, GLFW_OPENGL_CORE_PROFILE)
    glfwWindowHint(GLFW_RESIZABLE, GL_FALSE)
    glfwWindowHint(GLFW_OPENGL_FORWARD_COMPAT, GL_TRUE)
    
    let window = glfwCreateWindow(WIDTH, HEIGHT, "LearnSwiftGL", nil, nil)
    glfwMakeContextCurrent(window)
    guard window != nil else {
        print("Failed to create GLFW window")
        return
    }
    
    glfwSetKeyCallback(window, keyCallback)
    
    glViewport(x: 0, y: 0, width: WIDTH, height: HEIGHT)
    
    let ourShader = Shader(vertexFile: "textures.vs", fragmentFile: "textures.frag")
    
    // Set up vertex data
    let vertices: [GLfloat] = [
        // Positions       // Colors        // Texture Coords
        0.5,  0.5, 0.0,   1.0, 0.0, 0.0,   1.0, 1.0, // Top Right
        0.5, -0.5, 0.0,   0.0, 1.0, 0.0,   1.0, 0.0, // Bottom Right
        -0.5, -0.5, 0.0,   0.0, 0.0, 1.0,   0.0, 0.0, // Bottom Left
        -0.5,  0.5, 0.0,   1.0, 1.0, 0.0,   0.0, 1.0  // Top Left
    ]
    let indices: [GLuint] = [  // Note that we start from 0!
        0, 1, 3, // First Triangle
        1, 2, 3  // Second Triangle
    ]
    
    var VBO: GLuint = 0, EBO: GLuint = 0, VAO: GLuint = 0
    
    glGenVertexArrays(n: 1, arrays: &VAO)
    defer { glDeleteVertexArrays(1, &VAO) }
    
    glGenBuffers(n: 1, buffers: &VBO)
    defer { glDeleteBuffers(1, &VBO) }
    
    glGenBuffers(n: 1, buffers: &EBO)
    defer { glDeleteBuffers(1, &EBO) }
    
    glBindVertexArray(VAO)
    
    glBindBuffer(target: GL_ARRAY_BUFFER, buffer: VBO)
    glBufferData(target: GL_ARRAY_BUFFER,
                 size: MemoryLayout<GLfloat>.stride * vertices.count,
                 data: vertices, usage: GL_STATIC_DRAW)
    
    glBindBuffer(target: GL_ELEMENT_ARRAY_BUFFER, buffer: EBO)
    glBufferData(target: GL_ELEMENT_ARRAY_BUFFER,
                 size: MemoryLayout<GLuint>.stride * indices.count,
                 data: indices, usage: GL_STATIC_DRAW)
    
    // Position attribute
    let pointer0offset = UnsafeRawPointer(bitPattern: 0)
    glVertexAttribPointer(index: 0, size: 3, type: GL_FLOAT,
                          normalized: false,
                          stride: GLsizei(MemoryLayout<GLfloat>.stride * 8),
                          pointer: pointer0offset)
    glEnableVertexAttribArray(0)
    
    // Color attribute
    let pointer1offset = UnsafeRawPointer(bitPattern: MemoryLayout<GLfloat>.stride * 3)
    glVertexAttribPointer(index: 1, size: 3, type: GL_FLOAT,
                          normalized: false,
                          stride: GLsizei(MemoryLayout<GLfloat>.stride * 8),
                          pointer: pointer1offset)
    glEnableVertexAttribArray(1)
    
    // TexCoord attribute
    let pointer2offset = UnsafeRawPointer(bitPattern: MemoryLayout<GLfloat>.stride * 6)
    glVertexAttribPointer(index: 2, size: 2, type: GL_FLOAT,
                          normalized: false,
                          stride: GLsizei(MemoryLayout<GLfloat>.stride * 8),
                          pointer: pointer2offset)
    glEnableVertexAttribArray(2)
    
    glBindBuffer(target: GL_ARRAY_BUFFER, buffer: 0)
    glBindVertexArray(0)
    
    // Textures
    var texture1: GLuint = 0
    var texture2: GLuint = 0
    
    // Texture 1
    glGenTextures(1, &texture1)
    glBindTexture(GL_TEXTURE_2D, texture1)
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_REPEAT)
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_REPEAT)
    
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR)
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR)
    
    let loader1 = SGLImageLoader(fromFile: "container.png")
    if (loader1.error != nil) { fatalError(loader1.error!) }
    let image1 = SGLImageRGB<UInt8>(loader1)
    if (loader1.error != nil) { fatalError(loader1.error!) }
    
    // Mipmaps
    image1.withUnsafeMutableBufferPointer() {
        glTexImage2D(GL_TEXTURE_2D, 0, GL_RGB,
                     GLsizei(image1.width),
                     GLsizei(image1.height),
                     0, GL_RGB, GL_UNSIGNED_BYTE,
                     $0.baseAddress)
    }
    glGenerateMipmap(GL_TEXTURE_2D)
    
    glBindTexture(GL_TEXTURE_2D, 0)
    
    // Texture 2
    glGenTextures(1, &texture2)
    glBindTexture(GL_TEXTURE_2D, texture2)
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_REPEAT)
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_REPEAT)
    
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR)
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR)
    
    let loader2 = SGLImageLoader(fromFile: "awesomeface.png")
    loader2.flipVertical = true
    if (loader2.error != nil) { fatalError(loader2.error!) }
    let image2 = SGLImageRGBA<UInt8>(loader2)
    if (loader2.error != nil) { fatalError(loader2.error!) }
    
    // Mipmaps
    image2.withUnsafeMutableBufferPointer() {
        glTexImage2D(GL_TEXTURE_2D, 0, GL_RGBA,
                     GLsizei(image2.width),
                     GLsizei(image2.height),
                     0, GL_RGBA, GL_UNSIGNED_BYTE,
                     $0.baseAddress)
    }
    glGenerateMipmap(GL_TEXTURE_2D)
    
    glBindTexture(GL_TEXTURE_2D, 0)
    
    while glfwWindowShouldClose(window) == GL_FALSE {
        glfwPollEvents()
        
        glClearColor(red: 0.2, green: 0.3, blue: 0.3, alpha: 1.0)
        glClear(GL_COLOR_BUFFER_BIT)
        
        ourShader.use()
        
        glActiveTexture(GL_TEXTURE0)
        glBindTexture(GL_TEXTURE_2D, texture1)
        glUniform1i(glGetUniformLocation(ourShader.program, "ourTexture1"), 0)
        glActiveTexture(GL_TEXTURE1)
        glBindTexture(GL_TEXTURE_2D, texture2)
        glUniform1i(glGetUniformLocation(ourShader.program, "ourTexture2"), 1)
        
        glBindVertexArray(VAO)
        glDrawElements(GL_TRIANGLES, 6, GL_UNSIGNED_INT, nil)
        glBindVertexArray(0)
        
        glfwSwapBuffers(window)
    }
}

main()

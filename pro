import tkinter as tk
from tkinter import messagebox
from conexion import Conexion
from mysql.connector import Error
from datetime import datetime
import bcrypt  


class Empleados:
    def __init__(self, root):
        self.frame_empleados = tk.LabelFrame(root, text="Empleados")
        self.frame_empleados.pack(padx=10, pady=10, fill="both", expand="yes")

        tk.Label(self.frame_empleados, text="Nombre de Usuario:").grid(row=0, column=0)
        self.entry_nombre_usuario = tk.Entry(self.frame_empleados)
        self.entry_nombre_usuario.grid(row=0, column=1)
        
        tk.Label(self.frame_empleados, text="Contraseña:").grid(row=1, column=0)
        self.entry_contrasena = tk.Entry(self.frame_empleados, show='*')
        self.entry_contrasena.grid(row=1, column=1)

        tk.Label(self.frame_empleados, text="Nombre:").grid(row=2, column=0)
        self.entry_nombre = tk.Entry(self.frame_empleados)
        self.entry_nombre.grid(row=2, column=1)

        tk.Label(self.frame_empleados, text="Apellido:").grid(row=3, column=0)
        self.entry_apellido = tk.Entry(self.frame_empleados)
        self.entry_apellido.grid(row=3, column=1)

        tk.Label(self.frame_empleados, text="Dirección:").grid(row=4, column=0)
        self.entry_direccion = tk.Entry(self.frame_empleados)
        self.entry_direccion.grid(row=4, column=1)

        tk.Label(self.frame_empleados, text="Teléfono:").grid(row=5, column=0)
        self.entry_telefono = tk.Entry(self.frame_empleados)
        self.entry_telefono.grid(row=5, column=1)

        tk.Label(self.frame_empleados, text="Email:").grid(row=6, column=0)
        self.entry_email = tk.Entry(self.frame_empleados)
        self.entry_email.grid(row=6, column=1)

        tk.Label(self.frame_empleados, text="Fecha de Inicio:").grid(row=7, column=0)
        self.entry_fecha_inicio = tk.Entry(self.frame_empleados)
        self.entry_fecha_inicio.grid(row=7, column=1)

        tk.Label(self.frame_empleados, text="Sueldo:").grid(row=8, column=0)
        self.entry_sueldo = tk.Entry(self.frame_empleados)
        self.entry_sueldo.grid(row=8, column=1)

        tk.Label(self.frame_empleados, text="ID Departamento:").grid(row=9, column=0)
        self.entry_id_departamento = tk.Entry(self.frame_empleados)
        self.entry_id_departamento.grid(row=9, column=1)

        tk.Label(self.frame_empleados, text="Rol:").grid(row=10, column=0)
        self.entry_rol = tk.StringVar(value="Empleado")
        tk.OptionMenu(self.frame_empleados, self.entry_rol, "Gerente", "Empleado", "Admin").grid(row=10, column=1)

        tk.Button(self.frame_empleados, text="Registrar Usuario", command=self.registrar_usuario).grid(row=11, columnspan=2)

        tk.Button(self.frame_empleados, text="Ver Empleados", command=self.ver_empleados).grid(row=12, columnspan=2)
        
        tk.Button(self.frame_empleados, text="Actualizar Empleado", command=self.actualizar_empleado_ui).grid(row=13, columnspan=2)
        
        tk.Button(self.frame_empleados, text="Eliminar Empleado", command=self.eliminar_empleado_ui).grid(row=14, columnspan=2)
        
        self.listbox_empleados = tk.Listbox(self.frame_empleados, width=100)
        self.listbox_empleados.grid(row=15, columnspan=2, padx=10, pady=10)

    def hash_password(self, password):
        return bcrypt.hashpw(password.encode('utf-8'), bcrypt.gensalt()).decode('utf-8')

    def registrar_usuario(self):
        nombre_usuario = self.entry_nombre_usuario.get()
        contrasena = self.entry_contrasena.get()
        hashed_password = self.hash_password(contrasena)  
        nombre = self.entry_nombre.get()
        apellido = self.entry_apellido.get()
        direccion = self.entry_direccion.get()
        telefono = self.entry_telefono.get()
        email = self.entry_email.get()
        fecha_inicio = self.entry_fecha_inicio.get()
        sueldo = self.entry_sueldo.get()
        id_departamento = self.entry_id_departamento.get()
        rol = self.entry_rol.get()

        try:
            fecha_inicio = datetime.strptime(fecha_inicio, "%d-%m-%Y").strftime("%Y-%m-%d")
        except ValueError as e:
            messagebox.showerror("Error", f"Formato de fecha incorrecto: {e}")
            return

        conexion = Conexion.conectar()
        if conexion:
            cursor = conexion.cursor()
            try:
                cursor.execute("""
                    INSERT INTO Usuario (Nombre_Usuario, Contrasena, Nombre, Apellido, Dirección, Telefono, Email, Rol) 
                    VALUES (%s, %s, %s, %s, %s, %s, %s, %s)
                """, (nombre_usuario, hashed_password, nombre, apellido, direccion, telefono, email, rol))
                
                if rol == "Empleado":
                    cursor.execute("""
                        INSERT INTO Empleado (Nombre_Usuario, Fecha_inicio_contrato, Sueldo, ID_Departamento) 
                        VALUES (%s, %s, %s, %s)
                    """, (nombre_usuario, fecha_inicio, sueldo, id_departamento))
                
                conexion.commit()
                messagebox.showinfo("Éxito", "Usuario registrado con éxito")
                self.limpiar_campos()
            except Error as e:
                messagebox.showerror("Error", f"Error al registrar usuario: {e}")
            finally:
                cursor.close()
                conexion.close()
        else:
            messagebox.showerror("Error", "Error en la conexión a la base de datos")

    def ver_empleados(self):
        conexion = Conexion.conectar()
        if conexion:
            cursor = conexion.cursor()
            try:
                cursor.execute("""
                    SELECT u.Nombre_Usuario, u.Nombre, u.Apellido, u.Rol, d.Nombre_Departamento
                    FROM Usuario u
                    LEFT JOIN Empleado e ON u.Nombre_Usuario = e.Nombre_Usuario
                    LEFT JOIN Departamento d ON e.ID_Departamento = d.Id_Departamento
                """)
                empleados = cursor.fetchall()
                self.listbox_empleados.delete(0, tk.END)  
                for emp in empleados:
                    self.listbox_empleados.insert(tk.END, f"Usuario: {emp[0]}, Nombre: {emp[1]} {emp[2]}, Rol: {emp[3]}, Departamento: {emp[4]}")
            except Error as e:
                messagebox.showerror("Error", f"Error al obtener empleados: {e}")
            finally:
                cursor.close()
                conexion.close()
        else:
            messagebox.showerror("Error", "Error en la conexión a la base de datos")

    def actualizar_empleado_ui(self):
        top = tk.Toplevel(self.frame_empleados)
        top.title("Actualizar Empleado")
        
        tk.Label(top, text="Nombre de Usuario:").grid(row=0, column=0)
        entry_nombre_usuario = tk.Entry(top)
        entry_nombre_usuario.grid(row=0, column=1)
        
        tk.Label(top, text="Nuevo Nombre:").grid(row=1, column=0)
        entry_nuevo_nombre = tk.Entry(top)
        entry_nuevo_nombre.grid(row=1, column=1)
        
        tk.Label(top, text="Nuevo Apellido:").grid(row=2, column=0)
        entry_nuevo_apellido = tk.Entry(top)
        entry_nuevo_apellido.grid(row=2, column=1)
        
        tk.Label(top, text="Nueva Dirección:").grid(row=3, column=0)
        entry_nueva_direccion = tk.Entry(top)
        entry_nueva_direccion.grid(row=3, column=1)
        
        tk.Label(top, text="Nuevo Teléfono:").grid(row=4, column=0)
        entry_nuevo_telefono = tk.Entry(top)
        entry_nuevo_telefono.grid(row=4, column=1)
        
        tk.Label(top, text="Nuevo Email:").grid(row=5, column=0)
        entry_nuevo_email = tk.Entry(top)
        entry_nuevo_email.grid(row=5, column=1)
        
        tk.Label(top, text="Nueva Fecha de Inicio (DD-MM-YYYY):").grid(row=6, column=0)
        entry_nueva_fecha_inicio = tk.Entry(top)
        entry_nueva_fecha_inicio.grid(row=6, column=1)
        
        tk.Label(top, text="Nuevo Sueldo:").grid(row=7, column=0)
        entry_nuevo_sueldo = tk.Entry(top)
        entry_nuevo_sueldo.grid(row=7, column=1)
        
        tk.Label(top, text="Nuevo ID Departamento:").grid(row=8, column=0)
        entry_nuevo_id_departamento = tk.Entry(top)
        entry_nuevo_id_departamento.grid(row=8, column=1)

        
        tk.Button(top, text="Actualizar", command=lambda: self.actualizar_empleado(
            entry_nombre_usuario.get(),
            {
                'nombre': entry_nuevo_nombre.get(),
                'apellido': entry_nuevo_apellido.get(),
                'direccion': entry_nueva_direccion.get(),
                'telefono': entry_nuevo_telefono.get(),
                'email': entry_nuevo_email.get(),
                'fecha_inicio': entry_nueva_fecha_inicio.get(),
                'sueldo': entry_nuevo_sueldo.get(),
                'id_departamento': entry_nuevo_id_departamento.get()
            }
        )).grid(row=9, columnspan=2)

    def actualizar_empleado(self, nombre_usuario, nuevos_datos):
        conexion = Conexion.conectar()
        if conexion:
            cursor = conexion.cursor()
            try:
                # 
                try:
                    nuevos_datos['fecha_inicio'] = datetime.strptime(nuevos_datos['fecha_inicio'], "%d-%m-%Y").strftime("%Y-%m-%d")
                except ValueError as e:
                    messagebox.showerror("Error", f"Formato de fecha incorrecto: {e}")
                    return

                cursor.execute("""
                    UPDATE Usuario
                    SET Nombre = %s, Apellido = %s, Dirección = %s, Telefono = %s, Email = %s
                    WHERE Nombre_Usuario = %s
                """, (nuevos_datos['nombre'], nuevos_datos['apellido'], nuevos_datos['direccion'], nuevos_datos['telefono'], nuevos_datos['email'], nombre_usuario))

                cursor.execute("""
                    UPDATE Empleado
                    SET Fecha_inicio_contrato = %s, Sueldo = %s, ID_Departamento = %s
                    WHERE Nombre_Usuario = %s
                """, (nuevos_datos['fecha_inicio'], nuevos_datos['sueldo'], nuevos_datos['id_departamento'], nombre_usuario))

                conexion.commit()
                messagebox.showinfo("Éxito", "Empleado actualizado con éxito")
            except Error as e:
                messagebox.showerror("Error", f"Error al actualizar empleado: {e}")
            finally:
                cursor.close()
                conexion.close()
        else:
            messagebox.showerror("Error", "Error en la conexión a la base de datos")

    def eliminar_empleado_ui(self):
        top = tk.Toplevel(self.frame_empleados)
        top.title("Eliminar Empleado")
        
        tk.Label(top, text="Nombre de Usuario:").grid(row=0, column=0)
        entry_nombre_usuario = tk.Entry(top)
        entry_nombre_usuario.grid(row=0, column=1)
        
        tk.Button(top, text="Eliminar", command=lambda: self.eliminar_empleado(entry_nombre_usuario.get())).grid(row=1, columnspan=2)

    def eliminar_empleado(self, nombre_usuario):
        conexion = Conexion.conectar()
        if conexion:
            cursor = conexion.cursor()
            try:
                cursor.execute("DELETE FROM Empleado WHERE Nombre_Usuario = %s", (nombre_usuario,))
                cursor.execute("DELETE FROM Usuario WHERE Nombre_Usuario = %s", (nombre_usuario,))
                conexion.commit()
                messagebox.showinfo("Éxito", "Empleado eliminado con éxito")
            except Error as e:
                messagebox.showerror("Error", f"Error al eliminar empleado: {e}")
            finally:
                cursor.close()
                conexion.close()
        else:
            messagebox.showerror("Error", "Error en la conexión a la base de datos")

    def limpiar_campos(self):
        self.entry_nombre_usuario.delete(0, tk.END)
        self.entry_nombre.delete(0, tk.END)
        self.entry_apellido.delete(0, tk.END)
        self.entry_direccion.delete(0, tk.END)
        self.entry_telefono.delete(0, tk.END)
        self.entry_email.delete(0, tk.END)
        self.entry_fecha_inicio.delete(0, tk.END)
        self.entry_sueldo.delete(0, tk.END)
        self.entry_id_departamento.delete(0, tk.END)
        self.entry_rol.set("Empleado")

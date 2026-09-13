import express from "express";
import cors from "cors";
import pool from "./database/db.js";
import { z } from "zod";

const app = express();

app.use(express.json());
app.use(cors());

const postSchema = z.object({
  category_id: z.number({ required_error: "category_id required" }).int().min(1, "category_id must be a valid ID"),
  title: z.string().trim().min(1, "title required"),
  slug: z.string().trim().min(1, "slug required"),
  content: z.string().trim().min(1, "content required"),
});

const idSchema = z.object({
  id: z.union([z.string(), z.number()]),
});

const categorySchema = z.object({
  nama: z.string().trim().min(1, "category required"),
});

const updateSchema = postSchema.merge(idSchema);
const updateCategorySchema = categorySchema.merge(idSchema);

// --- validasi input ---
const validate = (schema, data, res) => {
  const result = schema.safeParse(data);
  if (!result.success) {
    res.status(400).json({ message: result.error.errors[0].message });
    return null;
  }
  return result.data;
};

// --- Create posts ---
app.post("/api/v1/posts", async (req, res) => {
  try {
    const body = validate(postSchema, req.body, res);
    if (!body) return;
    
    await pool.execute(
      "INSERT INTO posts (category_id, title, slug, content) VALUES (?, ?, ?, ?)",
      [body.category_id, body.title, body.slug, body.content]
    );
    
    return res.status(201).json({ message: `${body.title} successfully added` });
  } catch (error) {
    return res.status(500).json({ message: "server error", error: error.message });
  }
});

// Read
app.get("/api/v1/posts", async (req, res) => {
  try {
    const [posts] = await pool.query("SELECT * FROM posts");
    return res.status(200).json({ message: "success get all data", data: posts });
  } catch (error) {
    return res.status(500).json({ message: "server error", error });
  }
});

// Update
app.put("/api/v1/posts/:id", async (req, res) => {
  try {
    const { id } = req.params;
    const { title, slug, content } = req.body;
    
    const params = validate(updateSchema, { id, title, slug, content }, res);
    if (!params) return;

    const [result] = await pool.execute(
      "UPDATE posts SET title = ?, slug = ?, content = ? WHERE id = ?",
      [params.title, params.slug, params.content, params.id]
    );
    
    if (result.affectedRows === 0) {
      return res.status(404).json({ message: "posts not found" });
    }

    return res.status(200).json({ message: `${params.title} successfully updated` });
  } catch (error) {
    console.error("Backend Error Log:", error);
    return res.status(500).json({ message: "server error", error: error.message });
  }
});

// Delete
app.delete("/api/v1/posts/:id", async (req, res) => {
  try {
    const param = validate(idSchema, req.params, res);
    if (!param) return;
    
    const [result] = await pool.execute("DELETE FROM posts WHERE id = ?", [param.id]);
    
    if (result.affectedRows === 0) {
      return res.status(404).json({ message: "posts not found" });
    }
    
    return res.status(200).json({ message: `posts with id ${param.id} successfully deleted` });
  } catch (error) {
    return res.status(500).json({ message: "server error", error});
  }
});
// ----------------------------

// --- Create category ---
app.post("/api/v1/category", async (req, res) => {
  try {
    const body = validate(categorySchema, req.body, res);
    if (!body) return;
    
    await pool.execute(
      "INSERT INTO category (nama) VALUES (?)",
      [body.nama]
    );
    
    return res.status(200).json({ message: `${body.nama} successfully added` });
  } catch (error) {
    return res.status(500).json({ message: "server error", error });
  }
});

// Read
app.get("/api/v1/category", async (req, res) => {
  try {
    const [category] = await pool.query("SELECT * FROM category");
    return res.status(200).json({ message: "success get all data", data: category });
  } catch (error) {
    return res.status(500).json({ message: "server error", error });
  }
});

// Update
app.put("/api/v1/category/:id", async (req, res) => {
  try {
    const body = validate(updateCategorySchema, req.body, res);
    if (!body) return;

    const [result] = await pool.execute(
      "UPDATE category SET nama = ? WHERE id = ?",
      [body.nama, body.id]
    );
    
    if (result.affectedRows === 0) {
      return res.status(404).json({ message: "category not found" });
    }

    return res.status(200).json({ message: `${body.nama} successfully updated` });
  } catch (error) {
    return res.status(500).json({ message: "server error", error });
  }
});

// Delete
app.delete("/api/v1/category/:id", async (req, res) => {
  try {
    const body = validate(idSchema, req.body, res);
    if (!body) return;
    
    const [result] = await pool.execute("DELETE FROM category WHERE id = ?", [body.id]);
    
    if (result.affectedRows === 0) {
      return res.status(404).json({ message: "category not found" });
    }
    
    return res.status(200).json({ message: `category with id ${body.id} successfully deleted` });
  } catch (error) {
    return res.status(500).json({ message: "server error", error });
  }
});

app.listen(3000, () => {
  console.log("Server is running on port 3000");
});